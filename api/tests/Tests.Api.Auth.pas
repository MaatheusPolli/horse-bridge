unit Tests.Api.Auth;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TApiAuthTest = class
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure Login_Valido_Retorna200ComToken;
    [Test]
    procedure Login_SenhaErrada_Retorna401;
    [Test]
    procedure Login_SemBody_Retorna400;
    [Test]
    procedure RotaProtegida_SemToken_Retorna401;
    [Test]
    procedure RotaProtegida_TokenInvalido_Retorna401;
  end;

implementation

uses
  System.SysUtils, System.JSON, System.Net.HttpClient, System.Net.URLClient,
  Tests.TestSetup;

{ TApiAuthTest }

procedure TApiAuthTest.SetupFixture;
begin
  TTestSetup.StartServer;
end;

procedure TApiAuthTest.Login_Valido_Retorna200ComToken;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create('{"username":"admin","password":"admin123"}', TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/auth/login', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json')]);
    Assert.AreEqual(200, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.IsNotNull(LJson.GetValue('token'));
      Assert.AreEqual('Bearer', LJson.GetValue<string>('token_type'));
    finally
      LJson.Free;
    end;
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiAuthTest.Login_SenhaErrada_Retorna401;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create('{"username":"admin","password":"wrong"}', TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/auth/login', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json')]);
    Assert.AreEqual(401, LResponse.StatusCode);
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiAuthTest.Login_SemBody_Retorna400;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create('{}', TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/auth/login', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json')]);
    Assert.IsTrue(LResponse.StatusCode in [400, 401]);
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiAuthTest.RotaProtegida_SemToken_Retorna401;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create('{"sku":"X-001","nome":"Test","preco":10}', TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/produtos', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json')]);
    Assert.AreEqual(401, LResponse.StatusCode);
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiAuthTest.RotaProtegida_TokenInvalido_Retorna401;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create('{"sku":"X-001","nome":"Test","preco":10}', TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/produtos', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json'),
       TNetHeader.Create('Authorization', 'Bearer token-invalido')]);
    Assert.AreEqual(401, LResponse.StatusCode);
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

end.
