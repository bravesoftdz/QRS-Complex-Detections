unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, TAGraph,
  TASeries;

type
  my_Array = array [-10000..10000] of extended;

  { TForm1 }

  TForm1 = class(TForm)
    Chart2BarSeries1: TBarSeries;
    Chart4LineSeries1: TLineSeries;
    Chart7LineSeries2: TLineSeries;
    process: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Label13: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    close_project: TButton;
    dft_qrs: TButton;
    GroupBox3: TGroupBox;
    plot_ecg: TButton;
    OpenFile: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart1LineSeries3: TLineSeries;
    Chart1LineSeries4: TLineSeries;
    Chart2: TChart;
    Chart3: TChart;
    Chart3LineSeries1: TLineSeries;
    Chart4: TChart;
    Chart5: TChart;
    Chart5LineSeries1: TLineSeries;
    Chart6: TChart;
    Chart6LineSeries1: TLineSeries;
    Chart7: TChart;
    Chart7LineSeries1: TLineSeries;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    OpenDialog1: TOpenDialog;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    procedure processClick(Sender: TObject);
    procedure close_projectClick(Sender: TObject);
    procedure dft_qrsClick(Sender: TObject);
    procedure OpenFileClick(Sender: TObject);
    procedure plot_ecgClick(Sender: TObject);
    procedure windowing;
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    function s_cos (x,y,z: extended):extended;
    function s_sin (x,y,z: extended):extended;
  private

  public

  end;

var
  Form1: TForm1;
  fc_1, fc_2, jmlh_data, i, j, xy, p: integer;
  datax, rtor, puncak, u, ufix, derv, hpf, lpf, re_sig, im_sig, sqr_ing, my_dft, my_ecg: my_Array;
  file_ecg: TextFile;
  ambil: TStringList;
  fcy, ttl, bpm, t, th, fs, wc_1, wc_2, ym, total: extended;

implementation

{$R *.lfm}

{ TForm1 }
function TForm1.s_cos (x,y,z: extended):extended;
var
  sinyal: extended;
begin
  sinyal := cos(2*pi*x*y/z);
  result := sinyal;
end;

function TForm1.s_sin (x,y,z: extended):extended;
var
  sinyal: extended;
begin
  sinyal := sin(2*pi*x*y/z);
  result := sinyal;
end;

procedure TForm1.windowing ;
begin
  ScrollBar1.Max := ScrollBar2.Position;
  ScrollBar2.Max := jmlh_data;
  ScrollBar2.Min := ScrollBar1.Position+1;

  Chart1LineSeries3.Clear;
  for i:=-1 to 2 do
      Chart1LineSeries3.AddXY(ScrollBar1.Position,i);

  Chart1LineSeries4.Clear;
  for i:=-1 to 2 do
      Chart1LineSeries4.AddXY(ScrollBar2.Position,i);

  p := ScrollBar2.Position - ScrollBar1.Position;

  Chart1LineSeries2.Clear;
  u[i] := 0;
  j := 0;
  for i:=0 to p do
  begin
    u[i+ScrollBar1.Position] := 0.5-(0.5*s_cos(i,1,(p-1)));
    ufix[j]:= my_ecg[i+ScrollBar1.Position] * u[i+ScrollBar1.Position];
    Chart1LineSeries2.AddXY(i+ScrollBar1.Position,u[i+ScrollBar1.Position]);
    j := j + 1;
  end;
end;

procedure TForm1.OpenFileClick(Sender: TObject);
var
  del1, del2 :string;
begin
  if OpenDialog1.Execute then
  begin
    ambil := TStringList.Create;
    i := 0;
    assignfile(file_ecg,OpenDialog1.FileName);
    reset(file_ecg);
    readln(file_ecg,del1);
    ambil.Delimiter:='(';
    readln(file_ecg,del2);
    ambil.DelimitedText := del2;
    t := strtofloat (ambil[1]);
    while not EOF (file_ecg) do
    begin
      i := i + 1;
      readln(file_ecg,jmlh_data,my_ecg[jmlh_data]);
    end;
  end;
  closefile(file_ecg);
  jmlh_data := i;
  fs := 1/t;
  ShowMessage('Jumlah Data = ' + '' + inttostr(jmlh_data));
  ShowMessage('Frekuensi Sampling = ' + '' + floattostrf(fs,ffnumber,0,0));
end;

procedure TForm1.plot_ecgClick(Sender: TObject);
begin
  Chart1LineSeries1.Clear;
  Chart1LineSeries2.Clear;
  Chart1LineSeries3.Clear;
  Chart1LineSeries4.Clear;
  Chart2BarSeries1.Clear;
  Chart3LineSeries1.Clear;
  Chart4LineSeries1.Clear;
  Chart5LineSeries1.Clear;
  Chart6LineSeries1.Clear;
  Chart7LineSeries1.Clear;
  Chart7LineSeries2.Clear;
  ListBox1.Clear;
  ListBox2.Clear;
  Label9.Caption:= ' ';

  for i:=0 to jmlh_data-1 do
      Chart1LineSeries1.AddXY(i,my_ecg[i]);
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  windowing;
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  windowing;
end;

procedure TForm1.dft_qrsClick(Sender: TObject);
begin
  Chart4LineSeries1.Clear;
  for i:=0 to round((p-1)/2) do
  begin
    re_sig[i] := 0;
    im_sig[i] := 0;
    for j:= 0 to p do
    begin
      re_sig[i] := re_sig[i] + ufix[j]*s_cos(i,j,p);
      im_sig[i] := im_sig[i] - ufix[j]*s_sin(i,j,p);
    end;
    my_dft[i] := sqrt(sqr(re_sig[i]) + sqr(im_sig[i]));
  end;

  for i:=0 to round(fs/2) do
      Chart4LineSeries1.AddXY(i*fs/p,my_dft[i]);
end;

procedure TForm1.processClick(Sender: TObject);
begin
  Chart2BarSeries1.Clear;
  Chart3LineSeries1.Clear;
  Chart5LineSeries1.Clear;
  Chart6LineSeries1.Clear;
  Chart7LineSeries1.Clear;
  fc_1 := strtoint(Edit3.Text);
  fc_2 := strtoint(Edit4.Text);

  wc_1 := 2*pi*fc_1;
  wc_2 := 2*pi*fc_2;

  //BPF
  for i:=0 to jmlh_data do
  begin
    lpf[i] := ((8/sqr(t) - 2*sqr(wc_1))*lpf[i-1] - (4/sqr(t) - (2*sqrt(2)*wc_1)/t + sqr(wc_1))*lpf[i-2] + sqr(wc_1)*my_ecg[i] + 2*sqr(wc_1)*my_ecg[i-1] + sqr(wc_1)*my_ecg[i-2])/(4/sqr(t) + (2*sqrt(2)*wc_1)/t + sqr(wc_1));
    hpf[i] := ((8/sqr(t) - 2*sqr(wc_2))*hpf[i-1] - (4/sqr(t) -  2*sqrt(2)*wc_2/t + sqr(wc_2))*hpf[i-2] + 4/sqr(t)*lpf[i] - 8/sqr(t)*lpf[i-1] + 4/sqr(t)*lpf[i-2])/(4/sqr(t) + 2*sqrt(2)*wc_2/t + sqr(wc_2));
    Chart3LineSeries1.AddXY(i,hpf[i]);
  end;

  //DFT BPF
  for i:=0 to jmlh_data do
  begin
    re_sig[i] := 0;
    im_sig[i] := 0;
    for j:= 0 to jmlh_data do
    begin
      re_sig[i] := re_sig[i] + hpf[j]*s_cos(i,j,jmlh_data);
      im_sig[i] := im_sig[i] - hpf[j]*s_sin(i,j,jmlh_data);
    end;
    my_dft[i] := sqrt(sqr(re_sig[i]) + sqr(im_sig[i]));
    Chart2BarSeries1.AddXY(i*fs/jmlh_data,my_dft[i]);
  end;

  // derivatif dan squaring
  for i:=0 to jmlh_data do
  begin
     derv[i]    := (1/8)*(-hpf[i-2] - 2*hpf[i-1] + 2*hpf[i+1] + hpf[i+2]);
     sqr_ing[i] := sqr(derv[i]);
     Chart5LineSeries1.AddXY(i,derv[i]);
     Chart6LineSeries1.AddXY(i,sqr_ing[i]);
  end;

  //LPF dapatkan 1 peak
  for i:=0 to jmlh_data-1 do
  begin
    lpf[i] := ((8/sqr(t) - 2*sqr(wc_1))*lpf[i-1] - (4/sqr(t) - (2*sqrt(2)*wc_1)/t + sqr(wc_1))*lpf[i-2] + sqr(wc_1)*sqr_ing[i] + 2*sqr(wc_1)*sqr_ing[i-1] + sqr(wc_1)*sqr_ing[i-2])/(4/sqr(t) + (2*sqrt(2)*wc_1)/t + sqr(wc_1));
    Chart7LineSeries1.addxy(i,lpf[i]);
  end;

  //mencari titik tertinggi dr semua peak u cari th
  ym := 0;
  xy := 0;
  for i:=0 to jmlh_data-1 do
  begin
    if ym < lpf[i] then
    begin
      ym := lpf[i];
      xy := i;
    end;
  end;

  //penentuan th
  th := 0.5*ym;

  //cari heartrate
  j:=0;
  ttl := 0;
  for i:=0 to jmlh_data-1 do
  begin
    if lpf[i] > th then
    begin
      if (lpf[i]>lpf[i-1]) and (lpf[i]>lpf[i+1]) then
      begin
        puncak[i] := lpf[i];
        datax[j]  := i;
        rtor[j]   := datax[j] - datax[j-1];
        ttl       := ttl + rtor[j];
        ListBox1.Items.Add(floattostrf(puncak[i],ffnumber,1,5));
        ListBox2.Items.Add(floattostr(datax[j]));
        j := j + 1;
      end;
      bpm := 60*fs/(ttl/j); // rumus heartrate
      Label9.Caption:= floattostrf(bpm,ffnumber,0,0);
    end;
  end;
end;

procedure TForm1.close_projectClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.

