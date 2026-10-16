unit App.Config;

interface

type
  TAppConfig = class
  private
    class var FInstance: TAppConfig;
    FServerPort: Integer;
    FDbPath: string;
    FJwtSecret: string;
    FJwtExpirationMinutes: Integer;
    FCorsOrigin: string;
    FLogFormat: string;
  public
    class function GetInstance: TAppConfig;
    class procedure ReleaseInstance;
    procedure LoadFromEnv;

    property ServerPort: Integer read FServerPort;
    property DbPath: string read FDbPath;
    property JwtSecret: string read FJwtSecret;
    property JwtExpirationMinutes: Integer read FJwtExpirationMinutes;
    property CorsOrigin: string read FCorsOrigin;
    property LogFormat: string read FLogFormat;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

{ TAppConfig }

class function TAppConfig.GetInstance: TAppConfig;
begin
  if not Assigned(FInstance) then
    FInstance := TAppConfig.Create;
  Result := FInstance;
end;

class procedure TAppConfig.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

procedure TAppConfig.LoadFromEnv;

  function Env(const AName, ADefault: string): string;
  var
    LValue: string;
  begin
    LValue := GetEnvironmentVariable(AName);
    if LValue.IsEmpty then
      Result := ADefault
    else
      Result := LValue;
  end;

  procedure LoadDotEnv;
  var
    LLines: TArray<string>;
    LLine, LKey, LValue: string;
    LSep: Integer;
    LEnvFile: string;
  begin
    LEnvFile := TPath.Combine(ExtractFilePath(ParamStr(0)), '.env');
    if not TFile.Exists(LEnvFile) then
      Exit;
    LLines := TFile.ReadAllLines(LEnvFile);
    for LLine in LLines do
    begin
      if LLine.Trim.IsEmpty or LLine.Trim.StartsWith('#') then
        Continue;
      LSep := Pos('=', LLine);
      if LSep > 0 then
      begin
        LKey := Copy(LLine, 1, LSep - 1).Trim;
        LValue := Copy(LLine, LSep + 1, MaxInt).Trim;
        if GetEnvironmentVariable(LKey).IsEmpty then
          SetEnvironmentVariable(PChar(LKey), PChar(LValue));
      end;
    end;
  end;

begin
  LoadDotEnv;
  FServerPort := StrToIntDef(Env('SERVER_PORT', '9000'), 9000);
  FDbPath := Env('DB_PATH', '.\data\horsebridge.db');
  FJwtSecret := Env('JWT_SECRET', 'dev-secret-change-me');
  FJwtExpirationMinutes := StrToIntDef(Env('JWT_EXPIRATION_MINUTES', '60'), 60);
  FCorsOrigin := Env('CORS_ORIGIN', '*');
  FLogFormat := Env('LOG_FORMAT', 'json');
end;

end.
