unit Service.Categoria;

interface

uses
  System.Generics.Collections,
  Domain.Categoria, DTO.Produto, Repository.Categoria;

type
  ICategoriaService = interface
    ['{D5E6F7A8-B9C0-1234-5678-9ABCDEF01234}']
    function ListAll: TList<TCategoriaResponse>;
    function GetById(AId: Integer): TCategoriaResponse;
    function Create_(const ARequest: TCategoriaRequest): TCategoriaResponse;
    procedure Update(AId: Integer; const ARequest: TCategoriaRequest);
    procedure Delete(AId: Integer);
  end;

  TCategoriaService = class(TInterfacedObject, ICategoriaService)
  private
    FRepo: ICategoriaRepository;
    function ToResponse(const ACategoria: TCategoria): TCategoriaResponse;
  public
    constructor Create(ARepo: ICategoriaRepository);
    function ListAll: TList<TCategoriaResponse>;
    function GetById(AId: Integer): TCategoriaResponse;
    function Create_(const ARequest: TCategoriaRequest): TCategoriaResponse;
    procedure Update(AId: Integer; const ARequest: TCategoriaRequest);
    procedure Delete(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Domain.Exceptions;

{ TCategoriaService }

constructor TCategoriaService.Create(ARepo: ICategoriaRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TCategoriaService.ToResponse(const ACategoria: TCategoria): TCategoriaResponse;
begin
  Result.Id := ACategoria.Id;
  Result.Nome := ACategoria.Nome;
  Result.Ativo := ACategoria.Ativo;
end;

function TCategoriaService.ListAll: TList<TCategoriaResponse>;
var
  LCategorias: TList<TCategoria>;
  LCat: TCategoria;
begin
  Result := TList<TCategoriaResponse>.Create;
  LCategorias := FRepo.FindAll;
  try
    for LCat in LCategorias do
      Result.Add(ToResponse(LCat));
  finally
    LCategorias.Free;
  end;
end;

function TCategoriaService.GetById(AId: Integer): TCategoriaResponse;
begin
  Result := ToResponse(FRepo.FindById(AId));
end;

function TCategoriaService.Create_(const ARequest: TCategoriaRequest): TCategoriaResponse;
var
  LCategoria: TCategoria;
  LId: Integer;
begin
  if ARequest.Nome.Trim.IsEmpty then
    raise EValidationError.Create('Nome da categoria é obrigatório');

  if FRepo.ExistsByNome(ARequest.Nome) then
    raise EConflictError.CreateFmt('Categoria "%s" já existe', [ARequest.Nome]);

  LCategoria := Default(TCategoria);
  LCategoria.Nome := ARequest.Nome.Trim;
  LId := FRepo.Insert(LCategoria);
  Result := ToResponse(FRepo.FindById(LId));
end;

procedure TCategoriaService.Update(AId: Integer; const ARequest: TCategoriaRequest);
var
  LCategoria: TCategoria;
begin
  if ARequest.Nome.Trim.IsEmpty then
    raise EValidationError.Create('Nome da categoria é obrigatório');

  FRepo.FindById(AId);

  if FRepo.ExistsByNome(ARequest.Nome, AId) then
    raise EConflictError.CreateFmt('Categoria "%s" já existe', [ARequest.Nome]);

  LCategoria := Default(TCategoria);
  LCategoria.Id := AId;
  LCategoria.Nome := ARequest.Nome.Trim;
  FRepo.Update(LCategoria);
end;

procedure TCategoriaService.Delete(AId: Integer);
begin
  FRepo.FindById(AId);
  FRepo.SoftDelete(AId);
end;

end.
