object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Test Server'
  ClientHeight = 350
  ClientWidth = 558
  Color = clBtnShadow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object mLog: TMemo
    Left = 8
    Top = 8
    Width = 542
    Height = 281
    TabOrder = 0
  end
  object bClearLog: TButton
    Left = 464
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 1
    OnClick = bClearLogClick
  end
  object bRestartServer: TButton
    Left = 376
    Top = 312
    Width = 75
    Height = 25
    Caption = 'Restart'
    TabOrder = 2
    OnClick = bRestartServerClick
  end
end
