Unit Unit1;

Interface

Uses
  SysUtils, Forms, Dialogs, StdCtrls, Classes, Controls, INIfiles, Clipbrd;

Type
  TForm1 = Class(TForm)
    edtPassword: TEdit;
    grpStandard: TGroupBox;
    btnGenerate: TButton;
    edtLength: TEdit;
    chkUpper: TCheckBox;
    chkLower: TCheckBox;
    chkNumerals: TCheckBox;
    chkSymbols: TCheckBox;
    lblLength: TLabel;
    edtSymbols: TEdit;
    lblSymbols: TLabel;
    grpSpeakable: TGroupBox;
    lblSyllables: TLabel;
    edtSyllables: TEdit;
    lblNumerals: TLabel;
    edtNumerals: TEdit;
    btnGenSpeakable: TButton;
    Procedure btnGenerateClick(Sender: TObject);
    Function RandomPassword(PLen: Integer): String;
    Procedure btnGenSpeakableClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  Form1: TForm1;

Implementation

{$R *.dfm}

Function TForm1.RandomPassword(PLen: Integer): String;
Const
  Uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Lowercase = 'abcdefghijklmnopqrstuvwxyz';
  Numerals = '0123456789';
Var
  i: Integer;
  str: String;
Begin
  If PLen < 1 Then
  Begin
    ShowMessage('Password length must be at least 1!');
    exit;
  End;
  str := '';
  If chkUpper.Checked Then
    str := str + Uppercase;
  If chkLower.Checked Then
    str := str + Lowercase;
  If chkNumerals.Checked Then
    str := str + Numerals;
  If chkSymbols.Checked Then
    str := str + edtSymbols.Text;
  If str = '' Then
  Begin
    ShowMessage('You have to check the box for at least one set of characters!');
    exit;
  End;
  Result := '';
  Randomize;
  For i := 1 To PLen Do
    Result := Result + str[Random(Length(str)) + 1];
End;

Function GeneratePass(syllables, numbers: Byte): String;
// ex: GeneratePass(3,4)   =>   'yegise7955'
// ex: GeneratePass(5,0)   =>   'yagotoxa'
// ex: GeneratePass(0,9)   =>   '568597284'

  Function Replicate(Caracter: String; Quant: Integer): String;
  Var
    I: Integer;
  Begin
    Result := '';
    For I := 1 To Quant Do
      Result := Result + Caracter;
  End;

Const
  conso: Array[0..19] Of Char = ('b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z');
  vocal: Array[0..4] Of Char = ('a', 'e', 'i', 'o', 'u');
Var
  i: Integer;
  si, sf: Longint;
  n: String;
Begin
  Result := '';
  Randomize;
  If syllables <> 0 Then
    For i := 1 To syllables Do
    Begin
      Result := Result + conso[Random(19)];
      Result := Result + vocal[Random(4)];
    End;
  If numbers = 1 Then
    Result := Result + IntToStr(Random(9))
  Else If numbers >= 2 Then
  Begin
    If numbers > 9 Then
      numbers := 9;
    si := StrToInt('1' + Replicate('0', numbers - 1));
    sf := StrToInt(Replicate('9', numbers));
    n := FloatToStr(si + Random(sf));
    Result := Result + Copy(n, 0, numbers);
  End;
End;

Procedure TForm1.btnGenerateClick(Sender: TObject);
Begin
  edtPassword.Text := RandomPassword(StrToInt(edtLength.Text));
  Clipboard.AsText := edtPassword.Text;
End;

Procedure TForm1.btnGenSpeakableClick(Sender: TObject);
Begin
  edtPassword.Text := GeneratePass(StrToInt(edtSyllables.Text), StrToInt(edtNumerals.Text));
  Clipboard.AsText := edtPassword.Text;
End;

Procedure TForm1.FormClose(Sender: TObject; Var Action: TCloseAction);
Var
  myINI: TINIFile;
Begin
  //Save settings to INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'passgen.ini');
  myINI.WriteBool('Settings', 'UseUpper', chkUpper.Checked);
  myINI.WriteBool('Settings', 'UseLower', chkLower.Checked);
  myINI.WriteBool('Settings', 'UseNumerals', chkNumerals.Checked);
  myINI.WriteBool('Settings', 'UseSymbols', chkSymbols.Checked);
  myINI.WriteString('Settings', 'Symbols', edtSymbols.Text);
  myINI.WriteInteger('Settings', 'StandardLength', StrToInt(edtLength.Text));
  myINI.WriteInteger('Settings', 'SpeakableSyllables', StrToInt(edtSyllables.Text));
  myINI.WriteInteger('Settings', 'SpeakableNumerals', StrToInt(edtNumerals.Text));
  myINI.Free;
End;

Procedure TForm1.FormCreate(Sender: TObject);
Var
  myINI: TINIFile;
Begin
  //Initialise options from INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'passgen.ini');
  //Read settings from INI file
  chkUpper.Checked := myINI.ReadBool('Settings', 'UseUpper', True);
  chkLower.Checked := myINI.ReadBool('Settings', 'UseLower', True);
  chkNumerals.Checked := myINI.ReadBool('Settings', 'UseNumerals', True);
  chkSymbols.Checked := myINI.ReadBool('Settings', 'UseSymbols', True);
  edtSymbols.Text := myINI.ReadString('Settings', 'Symbols', '/?!£$%&@#/*-+[]{}(),.;:');
  edtLength.Text := IntToStr(myINI.ReadInteger('Settings', 'StandardLength', 8));
  edtSyllables.Text := IntToStr(myINI.ReadInteger('Settings', 'SpeakableSyllables', 4));
  edtNumerals.Text := IntToStr(myINI.ReadInteger('Settings', 'SpeakableNumerals', 2));
  myINI.Free;
End;

End.

