unit Repository.Categoria;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Domain.Categoria;

type
  ICategoriaRepository = interface
    ['{A2B3C4D5-E6F7-8901-2345-6789ABCDEF01}']
    function FindAll: TList<TCategoria>;
    function FindById(AId: Integer): TCategoria;
    function ExistsByNome(const ANome: string; AExcludeId: Integer = 0): Boolean;
    function Insert(const ACategoria: TCategoria): Integer;
    procedure Update(const ACategoria: TCategoria);
    procedure SoftDelete(AId: Integer);
  end;

  TCategoriaRepository = class(TInterfacedObject, ICategoriaRepository)
  private
    FConn: TFDConnection;
    function MapRow(AQuery: TFDQuery): TCategoria;
  public
    constructor Create(AConn: TFDConnection);
    function FindAll: TList<TCategoria>;
    function FindById(AId: Integer): TCategoria;
    function ExistsByNome(const ANome: string; AExcludeId: Integer = 0): Boolean;
    function Insert(const ACategoria: TCategoria): Integer;
    procedure Update(const ACategoria: TCategoria);
    procedure SoftDelete(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Domain.Exceptions;

{ TCategoriaRepository }

constructor TCategoriaRepository.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

function TCategoriaRepository.MapRow(AQuery: TFDQuery): TCategoria;
begin
  Result.Id := AQuery.FieldByName('id').AsInteger;
  Result.Nome := AQuery.FieldByName('nome').AsString;
  Result.Ativo := AQuery.FieldByName('ativo').AsInteger = 1;
  Result.CriadoEm := AQuery.FieldByName('criado_em').AsString;
  Result.AtualizadoEm := AQuery.FieldByName('atualizado_em').AsString;
end;

function TCategoriaRepository.FindAll: TList<TCategoria>;
var
  LQuery: TFDQuery;
begin
  Result := TList<TCategoria>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := 'SELECT * FROM categoria WHERE ativo = 1 ORDER BY nome';
    LQuery.Open;
    while not LQuery.Eof do
    begin
      Result.Add(MapRow(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TCategoriaRepository.FindById(AId: Integer): TCategoria;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := 'SELECT * FROM categoria WHERE id = :id AND ativo = 1';
    LQuery.ParamByName('id').AsInteger := AId;
    LQuery.Open;
    if LQuery.IsEmpty then
      raise ENotFoundError.CreateFmt('Categoria %d não encontrada', [AId]);
    Result := MapRow(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TCategoriaRepository.ExistsByNome(const ANome: string; AExcludeId: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS cnt FROM categoria WHERE LOWER(nome) = LOWER(:nome) AND ativo = 1 AND id <> :excludeId';
    LQuery.ParamByName('nome').AsString := ANome;
    LQuery.ParamByName('excludeId').AsInteger := AExcludeId;
    LQuery.Open;
    Result := LQuery.FieldByName('cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TCategoriaRepository.Insert(const ACategoria: TCategoria): Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text :=
      'INSERT INTO categoria (nome) VALUES (:nome)';
    LQuery.ParamByName('nome').AsString := ACategoria.Nome;
    LQuery.ExecSQL;

    LQuery.SQL.Text := 'SELECT last_insert_rowid() AS id';
    LQuery.Open;
    Result := LQuery.FieldByName('id').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TCategoriaRepository.Update(const ACategoria: TCategoria);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text :=
      'UPDATE categoria SET nome = :nome, atualizado_em = datetime(''now'') WHERE id = :id';
    LQuery.ParamByName('nome').AsString := ACategoria.Nome;
    LQuery.ParamByName('id').AsInteger := ACategoria.Id;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TCategoriaRepository.SoftDelete(AId: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := 'UPDATE categoria SET ativo = 0, atualizado_em = datetime(''now'') WHERE id = :id';
    LQuery.ParamByName('id').AsInteger := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
