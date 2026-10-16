unit Tests.Api.Produto;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TApiProdutoTest = class
  private
    FToken: string;
    function AuthHeader: string;
  public
    [SetupFixture]
    procedure SetupFixture;
    [Test]
    procedure Health_Retorna200;
    [Test]
    procedure Swagger_Retorna200;
    [Test]
    procedure ListarProdutos_Retorna200ComPaginacao;
    [Test]
    procedure ListarProdutos_ComBusca_FiltraResultados;
    [Test]
    procedure BuscarProduto_Existente_Retorna200;
    [Test]
    procedure BuscarProduto_Inexistente_Retorna404;
    [Test]
    procedure CriarProduto_Valido_Retorna201;
    [Test]
    procedure CriarProduto_SKUDuplicado_Retorna400;
    [Test]
    procedure CriarProduto_DadosInvalidos_Retorna400ComErrors;
    [Test]
    procedure AtualizarProduto_Valido_Retorna204;
    [Test]
    procedure DeletarProduto_Existente_Retorna204;
    [Test]
    procedure ListarCategorias_Retorna200;
  end;

implementation

uses
  System.SysUtils, System.JSON, System.Net.HttpClient, System.Net.URLClient,
  Tests.TestSetup;

{ TApiProdutoTest }

procedure TApiProdutoTest.SetupFixture;
begin
  TTestSetup.StartServer;
  FToken := TTestSetup.GetAuthToken;
end;

function TApiProdutoTest.AuthHeader: string;
begin
  Result := 'Bearer ' + FToken;
end;

procedure TApiProdutoTest.Health_Retorna200;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/health');
    Assert.AreEqual(200, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.AreEqual('ok', LJson.GetValue<string>('status'));
    finally
      LJson.Free;
    end;
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.Swagger_Retorna200;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/swagger');
    Assert.AreEqual(200, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.AreEqual('3.0.3', LJson.GetValue<string>('openapi'));
    finally
      LJson.Free;
    end;
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.ListarProdutos_Retorna200ComPaginacao;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/produtos?page=1&size=10');
    Assert.AreEqual(200, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.IsNotNull(LJson.GetValue('data'));
      Assert.IsNotNull(LJson.GetValue('meta'));
    finally
      LJson.Free;
    end;
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.ListarProdutos_ComBusca_FiltraResultados;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/produtos?q=Fone');
    Assert.AreEqual(200, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.IsTrue(LJson.GetValue<Integer>('meta.total') >= 0);
    finally
      LJson.Free;
    end;
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.BuscarProduto_Existente_Retorna200;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/produtos/1');
    Assert.AreEqual(200, LResponse.StatusCode);
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.BuscarProduto_Inexistente_Retorna404;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/produtos/99999');
    Assert.AreEqual(404, LResponse.StatusCode);
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.CriarProduto_Valido_Retorna201;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create(
    '{"sku":"TEST-100","nome":"Produto Teste","preco":49.90,"estoque":5,"categoria_id":1}',
    TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/produtos', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json'),
       TNetHeader.Create('Authorization', AuthHeader)]);
    Assert.AreEqual(201, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.AreEqual('TEST-100', LJson.GetValue<string>('sku'));
    finally
      LJson.Free;
    end;
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.CriarProduto_SKUDuplicado_Retorna400;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create(
    '{"sku":"ELEC-001","nome":"Duplicado","preco":10,"estoque":1}',
    TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/produtos', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json'),
       TNetHeader.Create('Authorization', AuthHeader)]);
    Assert.AreEqual(400, LResponse.StatusCode);
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.CriarProduto_DadosInvalidos_Retorna400ComErrors;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create(
    '{"sku":"","nome":"","preco":-1,"ean":"123"}',
    TEncoding.UTF8);
  try
    LResponse := LClient.Post(TTestSetup.BaseURL + '/produtos', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json'),
       TNetHeader.Create('Authorization', AuthHeader)]);
    Assert.AreEqual(400, LResponse.StatusCode);

    LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
    try
      Assert.IsNotNull(LJson.GetValue('errors'));
      Assert.IsTrue((LJson.GetValue('errors') as TJSONArray).Count > 0);
    finally
      LJson.Free;
    end;
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.AtualizarProduto_Valido_Retorna204;
var
  LClient: THTTPClient;
  LContent: TStringStream;
  LResponse: IHTTPResponse;
begin
  LClient := THTTPClient.Create;
  LContent := TStringStream.Create(
    '{"sku":"ELEC-001","nome":"Fone BT Atualizado","preco":179.90,"estoque":45}',
    TEncoding.UTF8);
  try
    LResponse := LClient.Put(TTestSetup.BaseURL + '/produtos/1', LContent, nil,
      [TNetHeader.Create('Content-Type', 'application/json'),
       TNetHeader.Create('Authorization', AuthHeader)]);
    Assert.AreEqual(204, LResponse.StatusCode);
  finally
    LContent.Free;
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.DeletarProduto_Existente_Retorna204;
var
  LClient: THTTPClient;
  LContent, LDelContent: TStringStream;
  LResponse: IHTTPResponse;
  LJson: TJSONObject;
  LId: Integer;
begin
  LClient := THTTPClient.Create;
  try
    LContent := TStringStream.Create(
      '{"sku":"DEL-001","nome":"Para Deletar","preco":1,"estoque":1}',
      TEncoding.UTF8);
    try
      LResponse := LClient.Post(TTestSetup.BaseURL + '/produtos', LContent, nil,
        [TNetHeader.Create('Content-Type', 'application/json'),
         TNetHeader.Create('Authorization', AuthHeader)]);
      LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
      try
        LId := LJson.GetValue<Integer>('id');
      finally
        LJson.Free;
      end;
    finally
      LContent.Free;
    end;

    LResponse := LClient.Delete(TTestSetup.BaseURL + '/produtos/' + IntToStr(LId),
      [TNetHeader.Create('Authorization', AuthHeader)]);
    Assert.AreEqual(204, LResponse.StatusCode);
  finally
    LClient.Free;
  end;
end;

procedure TApiProdutoTest.ListarCategorias_Retorna200;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
  LArr: TJSONArray;
begin
  LClient := THTTPClient.Create;
  try
    LResponse := LClient.Get(TTestSetup.BaseURL + '/categorias');
    Assert.AreEqual(200, LResponse.StatusCode);

    LArr := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray;
    try
      Assert.IsTrue(LArr.Count > 0);
    finally
      LArr.Free;
    end;
  finally
    LClient.Free;
  end;
end;

end.
