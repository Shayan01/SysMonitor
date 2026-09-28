unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Buttons, scControls, scGPControls, scGPMeters, Vcl.ExtCtrls;

type
  TRamStatusResult = record
    TotalPhys, AvailPhys, UsedPhys: UInt64;
  end;

  TForm1 = class(TForm)
    btn1: TBitBtn;
    scgpgrpbx1: TscGPGroupBox;
    scgprgrsbr1: TscGPProgressBar;
    scgpmtr1: TscGPMeter;
    scgplbl1: TscGPLabel;
    scgplbl2: TscGPLabel;
    scgplbl3: TscGPLabel;
    tmrCheckRAMStatus: TTimer;
    procedure btn1Click(Sender: TObject);
    procedure tmrCheckRAMStatusTimer(Sender: TObject);
  private
    procedure ShowRAMStatus;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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

procedure TForm1.ShowRAMStatus;
var
  RAMStatusResult: TRamStatusResult;
begin
  RAMStatusResult := GetTotalRAM;
  scgplbl1.Caption := 'فــــــــضـــای کـلی :' + ' ' + RAMStatusResult.TotalPhys.ToString + ' گیگ';
  scgplbl3.Caption := 'فـــــــضــــــــای آزاد :' + ' ' + RAMStatusResult.AvailPhys.ToString + ' گیگ';
  scgplbl2.Caption := 'فضای استفاده شده :' + ' ' + RAMStatusResult.AvailPhys.ToString + ' گیگ';
end;

procedure TForm1.tmrCheckRAMStatusTimer(Sender: TObject);
begin
ShowRAMStatus;
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  scgprgrsbr1.Value := Random(100);

  scgpmtr1.Value := Random(100);
end;

end.

