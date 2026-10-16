unit Controller.Produto;

interface

type
  TControllerProduto = class
  public
    class procedure RegisterRoutes;
  end;

implementation

uses
  System.SysUtils, System.JSON,
  Horse,
  App.Container, DTO.Produto, DTO.Paginacao, Middleware.Auth;

{ TControllerProduto }

class procedure TControllerProduto.RegisterRoutes;
begin
  THorse.Get('/produtos',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LPaginacao: TPaginacaoRequest;
      LResult: TJSONObject;
    begin
      LPaginacao.Page := StrToIntDef(Req.Query['page'], 1);
      LPaginacao.Size := StrToIntDef(Req.Query['size'], 20);
      LPaginacao.Query := Req.Query['q'];
      LPaginacao.Categoria := Req.Query['categoria'];
      LPaginacao.LoadDefaults;

      LResult := TContainer.GetInstance.ProdutoService.List(LPaginacao);
      Res.Send<TJSONObject>(LResult);
    end);

  THorse.Get('/produtos/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LId: Integer;
      LResult: TProdutoResponse;
    begin
      LId := StrToInt(Req.Params['id']);
      LResult := TContainer.GetInstance.ProdutoService.GetById(LId);
      Res.Send<TJSONObject>(LResult.ToJSON);
    end);

  THorse.Post('/produtos', TMiddlewareAuth.Validate,
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LRequest: TProdutoRequest;
      LResult: TProdutoResponse;
    begin
      LRequest := TProdutoRequest.FromJSON(Req.Body<TJSONObject>);
      LResult := TContainer.GetInstance.ProdutoService.Create_(LRequest);
      Res.Status(THTTPStatus.Created).Send<TJSONObject>(LResult.ToJSON);
    end);

  THorse.Put('/produtos/:id', TMiddlewareAuth.Validate,
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LId: Integer;
      LRequest: TProdutoRequest;
    begin
      LId := StrToInt(Req.Params['id']);
      LRequest := TProdutoRequest.FromJSON(Req.Body<TJSONObject>);
      TContainer.GetInstance.ProdutoService.Update(LId, LRequest);
      Res.Status(THTTPStatus.NoContent).Send('');
    end);

  THorse.Delete('/produtos/:id', TMiddlewareAuth.Validate,
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LId: Integer;
    begin
      LId := StrToInt(Req.Params['id']);
      TContainer.GetInstance.ProdutoService.Delete(LId);
      Res.Status(THTTPStatus.NoContent).Send('');
    end);
end;

end.
