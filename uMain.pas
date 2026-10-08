unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Buttons, scControls, scGPControls, scGPMeters, Vcl.ExtCtrls,
  scOpenFileDialog, scSelectPathDialog, System.Win.ComObj, Winapi.ActiveX;

type
  TRamStatusResult = record
    TotalPhys, AvailPhys, UsedPhys: UInt64;
  end;

  TSearchRecArray = array of TSearchRec;

  TForm1 = class(TForm)
    scgpgrpbx1: TscGPGroupBox;
    scgprgrsbr1: TscGPProgressBar;
    scgpmtr1: TscGPMeter;
    scgplbl1: TscGPLabel;
    scgplbl2: TscGPLabel;
    scgplbl3: TscGPLabel;
    tmrCheckRAMStatus: TTimer;
    scgrpbx1: TscGroupBox;
    btn1: TBitBtn;
    scListBox1: TscListBox;
    scSelectPathDialog1: TscSelectPathDialog;
    btn2: TscGPGlyphButton;
    scsvdlg1: TscSaveDialog;
    procedure tmrCheckRAMStatusTimer(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    procedure ShowRAMStatus;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GetCPUTemperature: Double;
var
  FSWbemLocator: OLEVariant;
  FWMIServices: OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject: OLEVariant;
  Enum: IEnumVariant;
  Fetched: LongWord;
  TempKelvin: Double;
begin
  Result := 0;
  try
  // green 0<= temp <= 65
  // yellow 65< temp <= 85
  // red 85< temp
    // مقداردهی اولیه WMI
    FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    FWMIServices := FSWbemLocator.ConnectServer('localhost', 'root\WMI', '', '');
    FWbemObjectSet := FWMIServices.ExecQuery('SELECT * FROM MSAcpi_ThermalZoneTemperature');
    Enum := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;

    // خواندن مقدار دما
    if Enum.Next(1, FWbemObject, Fetched) = S_OK then
    begin
      TempKelvin := FWbemObject.CurrentTemperature;
      // دمای WMI بر حسب کلوین ضرب در ۱۰ است
      Result := (TempKelvin - 2732) / 10;
    end;
  except
    // در صورت عدم پشتیبانی مادربرد یا دسترسی محدود
    Result := -1;
  end;
end;

function GetFiles(DirectoryWithFileNamePatern: string): TSearchRecArray;
var
  SearchRec: TSearchRec;
  Len: Cardinal;
begin
  try
    if FindFirst(PChar(DirectoryWithFileNamePatern), faAnyFile, SearchRec) = 0 then
    begin
      Len := 1;
      repeat
        SetLength(Result, Len);
        Result[Len - 1] := SearchRec;
        Inc(Len);
      until FindNext(SearchRec) <> 0;
      System.SysUtils.FindClose(SearchRec);
    end;
  except
    on E: Exception do
      ShowMessage('uOSHelperFunctions.GetFiles' + sLineBreak + E.Message);
  end;
end;

function GetTotalRAM: TRamStatusResult;
var
  MemStatus: TMemoryStatusEx;
begin
  FillChar(MemStatus, SizeOf(MemStatus), 0);
  MemStatus.dwLength := SizeOf(MemStatus);
  if GlobalMemoryStatusEx(MemStatus) then
  begin
    Result.TotalPhys := MemStatus.ullTotalPhys div (1024 * 1024 * 1024);
    Result.AvailPhys := MemStatus.ullAvailPhys div (1024 * 1024 * 1024);
    Result.UsedPhys := (MemStatus.ullTotalPhys - MemStatus.ullAvailPhys) div (1024 * 1024 * 1024);
  end
  else
  begin
    Result.TotalPhys := 0;
    Result.AvailPhys := 0;
    Result.UsedPhys := 0;
  end;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  SearchRecArray: TSearchRecArray;
  I: Integer;
begin
  if scSelectPathDialog1.Execute then
  begin
    SearchRecArray := GetFiles(scSelectPathDialog1.Path + '*.*');
    scListBox1.Clear;
    for I := Low(SearchRecArray) to High(SearchRecArray) do
      scListBox1.Items.Add(SearchRecArray[I].Name);
  end;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  scsvdlg1.Filter:='All Files|*.*|Text Files|*.txt';
if scsvdlg1.Execute then
   scListBox1.Items.SaveToFile(scsvdlg1.FileName);
end;

procedure TForm1.ShowRAMStatus;
var
  RAMStatusResult: TRamStatusResult;
begin
  RAMStatusResult := GetTotalRAM;
  scgprgrsbr1.MinValue := 0;
  scgpmtr1.MinValue := 0;
  scgpmtr1.MaxValue := RAMStatusResult.TotalPhys;
  scgprgrsbr1.MaxValue := RAMStatusResult.TotalPhys;
  scgpmtr1.Value := RAMStatusResult.UsedPhys;
  scgprgrsbr1.Value := RAMStatusResult.UsedPhys;
  // set color
  if RAMStatusResult.UsedPhys <= RAMStatusResult.TotalPhys div 2 then
  begin
    scgpmtr1.FillColor := $0080FF80;
    scgprgrsbr1.ProgressColor := $0080FF80;
  end
  else
  begin
    scgpmtr1.FillColor := $008080FF;
    scgprgrsbr1.ProgressColor := $008080FF;
  end;

  scgplbl1.Caption := 'فــــــــضـــای کـلی :' + ' ' + RAMStatusResult.TotalPhys.ToString + ' گیگ';
  scgplbl3.Caption := 'فـــــــضــــــــای آزاد :' + ' ' + RAMStatusResult.AvailPhys.ToString + ' گیگ';
  scgplbl2.Caption := 'فضای استفاده شده :' + ' ' + RAMStatusResult.UsedPhys.ToString + ' گیگ';
  scgpgrpbx1.Visible := True;
end;

procedure TForm1.tmrCheckRAMStatusTimer(Sender: TObject);
begin
  ShowRAMStatus;
  Caption := 'CPU Temp: ' + FloatToStrF(GetCPUTemperature, ffFixed, 4, 1) + ' °C'
end;

end.

