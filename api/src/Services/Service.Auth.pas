unit Service.Auth;

interface

uses
  System.JSON;

type
  IAuthService = interface
    ['{C4D5E6F7-A8B9-0123-4567-89ABCDEF0123}']
    function Login(const AUsername, APassword: string): TJSONObject;
  end;

  TAuthService = class(TInterfacedObject, IAuthService)
  public
    function Login(const AUsername, APassword: string): TJSONObject;
  end;

implementation

uses
  System.SysUtils, System.DateUtils,
  JOSE.Core.JWT, JOSE.Core.Builder,
  App.Config, Domain.Exceptions;

const
  ADMIN_USER = 'admin';
  ADMIN_PASS = 'admin123';

{ TAuthService }

function TAuthService.Login(const AUsername, APassword: string): TJSONObject;
var
  LConfig: TAppConfig;
  LJWT: TJWT;
  LToken: string;
begin
  if AUsername.IsEmpty or APassword.IsEmpty then
    raise EValidationError.Create('Usuário e senha são obrigatórios');

  if not ((AUsername = ADMIN_USER) and (APassword = ADMIN_PASS)) then
    raise EUnauthorizedError.Create('Credenciais inválidas');

  LConfig := TAppConfig.GetInstance;

  LJWT := TJWT.Create;
  try
    LJWT.Claims.Subject := AUsername;
    LJWT.Claims.IssuedAt := Now;
    LJWT.Claims.Expiration := IncMinute(Now, LConfig.JwtExpirationMinutes);
    LJWT.Claims.SetClaimOfType<string>('role', 'admin');

    LToken := TJOSE.SHA256CompactToken(LConfig.JwtSecret, LJWT);
  finally
    LJWT.Free;
  end;

  Result := TJSONObject.Create;
  Result.AddPair('token', LToken);
  Result.AddPair('expires_in', TJSONNumber.Create(LConfig.JwtExpirationMinutes * 60));
  Result.AddPair('token_type', 'Bearer');
end;

end.
