unit Tests.TestSetup;

interface

uses
  System.SysUtils, System.Threading,
  Horse, Horse.Jhonson, Horse.CORS,
  App.Config, App.Container, App.Routes,
  Middleware.ErrorHandler, Middleware.Logger,
  Infra.Connection, Infra.Migrations, Infra.Swagger;

type
  TTestSetup = class
  private
    class var FPort: Integer;
    class var FRunning: Boolean;
  public
    class procedure StartServer;
    class procedure StopServer;
    class function BaseURL: string;
    class function GetAuthToken: string;
    class property Port: Integer read FPort;
  end;

implementation

uses
  System.JSON, System.Net.HttpClient, System.Net.URLClient;

{ TTestSetup }

class procedure TTestSetup.StartServer;
begin
  if FRunning then
    Exit;

  Randomize;
  FPort := 9100 + Random(900);

  TConnectionFactory.Initialize(':memory:');
  TMigrationRunner.Execute(TConnectionFactory.GetConnection);
  TContainer.GetInstance.Build;

  THorse
    .Use(Jhonson)
    .Use(CORS)
    .Use(TMiddlewareErrorHandler.Execute);

  RegisterRoutes;
  TSwaggerSetup.Register;

  TTask.Run(
    procedure
    begin
      THorse.Listen(FPort);
    end);

  Sleep(500);
  FRunning := True;
end;

class procedure TTestSetup.StopServer;
begin
  if not FRunning then
    Exit;
  THorse.StopListen;
  TConnectionFactory.Finalize;
  FRunning := False;
end;

class function TTestSetup.BaseURL: string;
begin
  Result := Format('http://localhost:%d', [FPort]);
end;

class function TTestSetup.GetAuthToken: string;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create('{"username":"admin","password":"admin123"}', TEncoding.UTF8);
  try
    LContent.Position := 0;
    LResponse := LClient.Post(BaseURL + '/auth/login', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json')]);
    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Result := LJson.GetValue<string>('token');
    finally
      LJson.Free;
    end;
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

end.
