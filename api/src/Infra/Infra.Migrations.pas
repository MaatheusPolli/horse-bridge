unit Infra.Migrations;

interface

uses
  FireDAC.Comp.Client;

type
  TMigrationRunner = class
  public
    class procedure Execute(AConn: TFDConnection);
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, System.Generics.Collections,
  System.Generics.Defaults;

{ TMigrationRunner }

class procedure TMigrationRunner.Execute(AConn: TFDConnection);
var
  LMigDir: string;
  LFiles: TArray<string>;
  LFile, LSQL: string;
  LApplied: TList<string>;
  LQuery: TFDQuery;
begin
  AConn.ExecSQL(
    'CREATE TABLE IF NOT EXISTS _migrations (' +
    '  name TEXT PRIMARY KEY, ' +
    '  applied_at TEXT NOT NULL DEFAULT (datetime(''now''))' +
    ')'
  );

  LMigDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'migrations');
  if not TDirectory.Exists(LMigDir) then
  begin
    Writeln('[migrations] Diretório não encontrado: ', LMigDir);
    Exit;
  end;

  LFiles := TDirectory.GetFiles(LMigDir, '*.sql');
  TArray.Sort<string>(LFiles, TComparer<string>.Construct(
    function(const A, B: string): Integer
    begin
      Result := CompareText(ExtractFileName(A), ExtractFileName(B));
    end));

  LApplied := TList<string>.Create;
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := AConn;
    LQuery.SQL.Text := 'SELECT name FROM _migrations';
    LQuery.Open;
    while not LQuery.Eof do
    begin
      LApplied.Add(LQuery.FieldByName('name').AsString);
      LQuery.Next;
    end;
    LQuery.Close;

    for LFile in LFiles do
    begin
      var LName := ExtractFileName(LFile);
      if LApplied.Contains(LName) then
        Continue;

      LSQL := TFile.ReadAllText(LFile, TEncoding.UTF8);
      Writeln('[migrations] Aplicando: ', LName);

      AConn.StartTransaction;
      try
        AConn.ExecSQL(LSQL);
        AConn.ExecSQL('INSERT INTO _migrations (name) VALUES (:name)', [LName]);
        AConn.Commit;
      except
        AConn.Rollback;
        raise;
      end;
    end;
  finally
    LQuery.Free;
    LApplied.Free;
  end;
end;

end.
