unit Tests.Validators;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TValidatorsTest = class
  public
    [Test]
    procedure EAN13_Valido;
    [Test]
    procedure EAN13_Invalido_Checksum;
    [Test]
    procedure EAN13_Invalido_Tamanho;
    [Test]
    procedure EAN13_Vazio_Aceito;
    [Test]
    procedure EAN13_Invalido_Letras;
    [Test]
    procedure SKU_Valido;
    [Test]
    procedure SKU_Invalido_Vazio;
    [Test]
    procedure SKU_Invalido_Minusculas;
    [Test]
    procedure SKU_Invalido_MuitoLongo;
    [Test]
    procedure SKU_Invalido_Espacos;
  end;

implementation

uses
  Domain.Validators;

{ TValidatorsTest }

procedure TValidatorsTest.EAN13_Valido;
begin
  Assert.IsTrue(TValidators.IsValidEAN13('7891234567890'));
end;

procedure TValidatorsTest.EAN13_Invalido_Checksum;
begin
  Assert.IsFalse(TValidators.IsValidEAN13('7891234567899'));
end;

procedure TValidatorsTest.EAN13_Invalido_Tamanho;
begin
  Assert.IsFalse(TValidators.IsValidEAN13('12345'));
end;

procedure TValidatorsTest.EAN13_Vazio_Aceito;
begin
  Assert.IsTrue(TValidators.IsValidEAN13(''));
end;

procedure TValidatorsTest.EAN13_Invalido_Letras;
begin
  Assert.IsFalse(TValidators.IsValidEAN13('789ABC4567890'));
end;

procedure TValidatorsTest.SKU_Valido;
begin
  Assert.IsTrue(TValidators.IsValidSKU('ELEC-001'));
  Assert.IsTrue(TValidators.IsValidSKU('ABC'));
  Assert.IsTrue(TValidators.IsValidSKU('A1B-2C3'));
end;

procedure TValidatorsTest.SKU_Invalido_Vazio;
begin
  Assert.IsFalse(TValidators.IsValidSKU(''));
end;

procedure TValidatorsTest.SKU_Invalido_Minusculas;
begin
  Assert.IsFalse(TValidators.IsValidSKU('elec-001'));
end;

procedure TValidatorsTest.SKU_Invalido_MuitoLongo;
begin
  Assert.IsFalse(TValidators.IsValidSKU('ABCDEFGHIJKLMNOPQRSTUVWXYZ'));
end;

procedure TValidatorsTest.SKU_Invalido_Espacos;
begin
  Assert.IsFalse(TValidators.IsValidSKU('AB CD'));
end;

end.
