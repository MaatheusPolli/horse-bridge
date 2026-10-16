unit DTO.Paginacao;

interface

uses
  System.JSON;

type
  TPaginacaoRequest = record
    Page: Integer;
    Size: Integer;
    Query: string;
    Categoria: string;
    procedure LoadDefaults;
  end;

  TPaginacaoMeta = record
    Page: Integer;
    Size: Integer;
    Total: Integer;
    TotalPages: Integer;
    function ToJSON: TJSONObject;
  end;

  TPaginatedResponse = record
    Data: TJSONArray;
    Meta: TPaginacaoMeta;
    function ToJSON: TJSONObject;
  end;

implementation

uses
  System.Math;

{ TPaginacaoRequest }

procedure TPaginacaoRequest.LoadDefaults;
begin
  if Page < 1 then
    Page := 1;
  if Size < 1 then
    Size := 20;
  if Size > 100 then
    Size := 100;
end;

{ TPaginacaoMeta }

function TPaginacaoMeta.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('page', TJSONNumber.Create(Page));
  Result.AddPair('size', TJSONNumber.Create(Size));
  Result.AddPair('total', TJSONNumber.Create(Total));
  Result.AddPair('total_pages', TJSONNumber.Create(TotalPages));
end;

{ TPaginatedResponse }

function TPaginatedResponse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('data', Data);
  Result.AddPair('meta', Meta.ToJSON);
end;

end.
