unit Controller.Categoria;

interface

type
  TControllerCategoria = class
  public
    class procedure RegisterRoutes;
  end;

implementation

uses
  System.SysUtils, System.JSON, System.Generics.Collections,
  Horse,
  App.Container, DTO.Produto, Middleware.Auth;

{ TControllerCategoria }

class procedure TControllerCategoria.RegisterRoutes;
begin
  THorse.Get('/categorias',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LList: TList<TCategoriaResponse>;
      LArr: TJSONArray;
      LItem: TCategoriaResponse;
    begin
      LList := TContainer.GetInstance.CategoriaService.ListAll;
      try
        LArr := TJSONArray.Create;
        for LItem in LList do
          LArr.Add(LItem.ToJSON);
        Res.Send<TJSONArray>(LArr);
      finally
        LList.Free;
      end;
    end);

  THorse.Get('/categorias/:id',
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LId: Integer;
      LResult: TCategoriaResponse;
    begin
      LId := StrToInt(Req.Params['id']);
      LResult := TContainer.GetInstance.CategoriaService.GetById(LId);
      Res.Send<TJSONObject>(LResult.ToJSON);
    end);

  THorse.Post('/categorias', TMiddlewareAuth.Validate,
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LRequest: TCategoriaRequest;
      LResult: TCategoriaResponse;
    begin
      LRequest := TCategoriaRequest.FromJSON(Req.Body<TJSONObject>);
      LResult := TContainer.GetInstance.CategoriaService.Create_(LRequest);
      Res.Status(THTTPStatus.Created).Send<TJSONObject>(LResult.ToJSON);
    end);

  THorse.Put('/categorias/:id', TMiddlewareAuth.Validate,
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LId: Integer;
      LRequest: TCategoriaRequest;
    begin
      LId := StrToInt(Req.Params['id']);
      LRequest := TCategoriaRequest.FromJSON(Req.Body<TJSONObject>);
      TContainer.GetInstance.CategoriaService.Update(LId, LRequest);
      Res.Status(THTTPStatus.NoContent).Send('');
    end);

  THorse.Delete('/categorias/:id', TMiddlewareAuth.Validate,
    procedure(Req: THorseRequest; Res: THorseResponse)
    var
      LId: Integer;
    begin
      LId := StrToInt(Req.Params['id']);
      TContainer.GetInstance.CategoriaService.Delete(LId);
      Res.Status(THTTPStatus.NoContent).Send('');
    end);
end;

end.
