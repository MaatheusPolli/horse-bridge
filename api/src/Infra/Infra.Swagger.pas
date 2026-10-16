unit Infra.Swagger;

interface

uses
  Horse;

type
  TSwaggerSetup = class
  public
    class procedure Register;
  end;

implementation

uses
  System.SysUtils, System.JSON;

{ TSwaggerSetup }

class procedure TSwaggerSetup.Register;
var
  LSpec: TJSONObject;
begin
  LSpec := TJSONObject.Create;

  LSpec.AddPair('openapi', '3.0.3');

  var LInfo := TJSONObject.Create;
  LInfo.AddPair('title', 'Horse Bridge API');
  LInfo.AddPair('description', 'API REST de catálogo de produtos em Delphi + Horse');
  LInfo.AddPair('version', '1.0.0');
  LSpec.AddPair('info', LInfo);

  var LServers := TJSONArray.Create;
  var LServer := TJSONObject.Create;
  LServer.AddPair('url', 'http://localhost:9000');
  LServer.AddPair('description', 'Local');
  LServers.Add(LServer);
  LSpec.AddPair('servers', LServers);

  var LComponents := TJSONObject.Create;
  var LSecSchemes := TJSONObject.Create;
  var LBearer := TJSONObject.Create;
  LBearer.AddPair('type', 'http');
  LBearer.AddPair('scheme', 'bearer');
  LBearer.AddPair('bearerFormat', 'JWT');
  LSecSchemes.AddPair('bearerAuth', LBearer);
  LComponents.AddPair('securitySchemes', LSecSchemes);
  LSpec.AddPair('components', LComponents);

  var LPaths := TJSONObject.Create;

  // POST /auth/login
  var LLoginPost := TJSONObject.Create;
  LLoginPost.AddPair('summary', 'Autenticar usuário');
  LLoginPost.AddPair('tags', TJSONArray.Create.Add('Auth'));
  var LLoginBody := TJSONObject.Create;
  var LLoginContent := TJSONObject.Create;
  var LLoginSchema := TJSONObject.Create;
  LLoginSchema.AddPair('type', 'object');
  var LLoginProps := TJSONObject.Create;
  var LUserProp := TJSONObject.Create;
  LUserProp.AddPair('type', 'string');
  LLoginProps.AddPair('username', LUserProp);
  var LPassProp := TJSONObject.Create;
  LPassProp.AddPair('type', 'string');
  LLoginProps.AddPair('password', LPassProp);
  LLoginSchema.AddPair('properties', LLoginProps);
  var LLoginMediaType := TJSONObject.Create;
  LLoginMediaType.AddPair('schema', LLoginSchema);
  LLoginContent.AddPair('application/json', LLoginMediaType);
  LLoginBody.AddPair('content', LLoginContent);
  LLoginPost.AddPair('requestBody', LLoginBody);
  var LLoginResponses := TJSONObject.Create;
  var L200 := TJSONObject.Create;
  L200.AddPair('description', 'Token JWT');
  LLoginResponses.AddPair('200', L200);
  var L401 := TJSONObject.Create;
  L401.AddPair('description', 'Credenciais inválidas');
  LLoginResponses.AddPair('401', L401);
  LLoginPost.AddPair('responses', LLoginResponses);
  var LAuthLogin := TJSONObject.Create;
  LAuthLogin.AddPair('post', LLoginPost);
  LPaths.AddPair('/auth/login', LAuthLogin);

  // GET /produtos
  var LProdutosGet := TJSONObject.Create;
  LProdutosGet.AddPair('summary', 'Listar produtos com paginação e busca');
  LProdutosGet.AddPair('tags', TJSONArray.Create.Add('Produtos'));
  var LProdParams := TJSONArray.Create;
  for var LParamName in ['page', 'size', 'q', 'categoria'] do
  begin
    var LParam := TJSONObject.Create;
    LParam.AddPair('name', LParamName);
    LParam.AddPair('in', 'query');
    LParam.AddPair('required', TJSONBool.Create(False));
    var LParamSchema := TJSONObject.Create;
    if (LParamName = 'page') or (LParamName = 'size') then
      LParamSchema.AddPair('type', 'integer')
    else
      LParamSchema.AddPair('type', 'string');
    LParam.AddPair('schema', LParamSchema);
    LProdParams.Add(LParam);
  end;
  LProdutosGet.AddPair('parameters', LProdParams);
  var LProdGetResp := TJSONObject.Create;
  var LProd200 := TJSONObject.Create;
  LProd200.AddPair('description', 'Lista paginada de produtos');
  LProdGetResp.AddPair('200', LProd200);
  LProdutosGet.AddPair('responses', LProdGetResp);
  var LProdutosPath := TJSONObject.Create;
  LProdutosPath.AddPair('get', LProdutosGet);

  // POST /produtos
  var LProdutosPost := TJSONObject.Create;
  LProdutosPost.AddPair('summary', 'Criar produto');
  LProdutosPost.AddPair('tags', TJSONArray.Create.Add('Produtos'));
  var LProdPostResp := TJSONObject.Create;
  var LProd201 := TJSONObject.Create;
  LProd201.AddPair('description', 'Produto criado');
  LProdPostResp.AddPair('201', LProd201);
  LProdutosPost.AddPair('responses', LProdPostResp);
  LProdutosPath.AddPair('post', LProdutosPost);
  LPaths.AddPair('/produtos', LProdutosPath);

  // GET/PUT/DELETE /produtos/{id}
  var LProdutoIdPath := TJSONObject.Create;
  var LProdGetById := TJSONObject.Create;
  LProdGetById.AddPair('summary', 'Buscar produto por ID');
  LProdGetById.AddPair('tags', TJSONArray.Create.Add('Produtos'));
  var LProdIdResp := TJSONObject.Create;
  var LProdId200 := TJSONObject.Create;
  LProdId200.AddPair('description', 'Produto encontrado');
  LProdIdResp.AddPair('200', LProdId200);
  LProdGetById.AddPair('responses', LProdIdResp);
  LProdutoIdPath.AddPair('get', LProdGetById);

  var LProdPut := TJSONObject.Create;
  LProdPut.AddPair('summary', 'Atualizar produto');
  LProdPut.AddPair('tags', TJSONArray.Create.Add('Produtos'));
  var LProdPutResp := TJSONObject.Create;
  var LProd204 := TJSONObject.Create;
  LProd204.AddPair('description', 'Produto atualizado');
  LProdPutResp.AddPair('204', LProd204);
  LProdPut.AddPair('responses', LProdPutResp);
  LProdutoIdPath.AddPair('put', LProdPut);

  var LProdDel := TJSONObject.Create;
  LProdDel.AddPair('summary', 'Excluir produto (soft delete)');
  LProdDel.AddPair('tags', TJSONArray.Create.Add('Produtos'));
  var LProdDelResp := TJSONObject.Create;
  var LProdDel204 := TJSONObject.Create;
  LProdDel204.AddPair('description', 'Produto excluído');
  LProdDelResp.AddPair('204', LProdDel204);
  LProdDel.AddPair('responses', LProdDelResp);
  LProdutoIdPath.AddPair('delete', LProdDel);
  LPaths.AddPair('/produtos/{id}', LProdutoIdPath);

  // GET /categorias
  var LCategoriasPath := TJSONObject.Create;
  var LCategoriasGet := TJSONObject.Create;
  LCategoriasGet.AddPair('summary', 'Listar categorias');
  LCategoriasGet.AddPair('tags', TJSONArray.Create.Add('Categorias'));
  var LCatGetResp := TJSONObject.Create;
  var LCat200 := TJSONObject.Create;
  LCat200.AddPair('description', 'Lista de categorias');
  LCatGetResp.AddPair('200', LCat200);
  LCategoriasGet.AddPair('responses', LCatGetResp);
  LCategoriasPath.AddPair('get', LCategoriasGet);
  LPaths.AddPair('/categorias', LCategoriasPath);

  // GET /health
  var LHealthPath := TJSONObject.Create;
  var LHealthGet := TJSONObject.Create;
  LHealthGet.AddPair('summary', 'Health check');
  LHealthGet.AddPair('tags', TJSONArray.Create.Add('Sistema'));
  var LHealthResp := TJSONObject.Create;
  var LHealth200 := TJSONObject.Create;
  LHealth200.AddPair('description', 'API ok');
  LHealthResp.AddPair('200', LHealth200);
  LHealthGet.AddPair('responses', LHealthResp);
  LHealthPath.AddPair('get', LHealthGet);
  LPaths.AddPair('/health', LHealthPath);

  LSpec.AddPair('paths', LPaths);

  THorse.Get('/swagger',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      Res.ContentType('application/json')
         .Send<TJSONObject>(LSpec.Clone as TJSONObject);
    end);
end;

end.
