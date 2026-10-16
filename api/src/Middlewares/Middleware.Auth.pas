unit Middleware.Auth;

interface

uses
  Horse;

type
  TMiddlewareAuth = class
  public
    class procedure Validate(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

uses
  System.SysUtils, System.JSON,
  JOSE.Core.JWT, JOSE.Core.Builder,
  App.Config, Domain.Exceptions;

{ TMiddlewareAuth }

class procedure TMiddlewareAuth.Validate(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LAuth, LToken: string;
  LJWT: TJWT;
  LConfig: TAppConfig;
begin
  LAuth := Req.Headers['Authorization'];
  if LAuth.IsEmpty then
    raise EUnauthorizedError.Create('Token não informado');

  if not LAuth.StartsWith('Bearer ', True) then
    raise EUnauthorizedError.Create('Formato de token inválido');

  LToken := Copy(LAuth, 8, MaxInt);
  LConfig := TAppConfig.GetInstance;

  LJWT := TJOSE.Verify(LConfig.JwtSecret, LToken);
  try
    if not LJWT.Verified then
      raise EUnauthorizedError.Create('Token inválido ou expirado');

    if LJWT.Claims.Expiration < Now then
      raise EUnauthorizedError.Create('Token expirado');

    Req.Session(LJWT.Claims.CloneNode as TJSONObject);
  finally
    LJWT.Free;
  end;

  Next;
end;

end.
