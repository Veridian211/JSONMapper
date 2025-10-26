unit JSONMapper.PublicFieldIterator;

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}

interface

uses
  {$IFDEF USE_ATTRIBUTE_HELPER}
  JSONMapper.AttributeHelper,
  {$ENDIF}
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  JSONMapper.Attributes;

type
  TRttiInstanceTypeHelper = class helper for TRttiInstanceType
  public
    function GetPublicProperties(): TArray<TRttiProperty>;
    function GetPublicFields(): TArray<TRttiField>;
  end;

  TRttiRecordTypeHelper = class helper for TRttiRecordType
  public
    function GetPublicFields: TArray<TRttiField>;
  end;

implementation

function isPublicOrPublished(rttiField: TRttiField): boolean; overload;
begin
  exit(rttiField.Visibility in [mvPublic, mvPublished]);
end;

function isPublicOrPublished(rttiProperty: TRttiProperty): boolean; overload;
begin
  exit(rttiProperty.Visibility in [mvPublic, mvPublished]);
end;

{ TRttiInstanceTypeHelper }

function TRttiInstanceTypeHelper.GetPublicFields: TArray<TRttiField>;
var
  rttiFields: TList<TRttiField>;
  rttiField: TRttiField;
begin
  rttiFields := TList<TRttiField>.Create;
  try
    for rttiField in self.GetFields() do begin
      if not isPublicOrPublished(rttiField) then
        continue;
      if rttiField.HasAttribute(IgnoreAttribute) then
        continue;
      rttiFields.Add(rttiField);
    end;
    exit(rttiFields.ToArray);
  finally
    rttiFields.Free;
  end;
end;

function TRttiInstanceTypeHelper.GetPublicProperties: TArray<TRttiProperty>;
var
  rttiProperties: TList<TRttiProperty>;
  rttiProperty: TRttiProperty;
begin
  rttiProperties := TList<TRttiProperty>.Create;
  try
    for rttiProperty in self.GetProperties() do begin
      if not isPublicOrPublished(rttiProperty) then
        continue;
      if rttiProperty.HasAttribute(IgnoreAttribute) then
        continue;
      rttiProperties.Add(rttiProperty);
    end;
    exit(rttiProperties.ToArray);
  finally
    rttiProperties.Free;
  end;
end;

{ TRttiRecordTypeHelper }

function TRttiRecordTypeHelper.GetPublicFields(): TArray<TRttiField>;
var
  rttiFields: TList<TRttiField>;
  rttiField: TRttiField;
begin
  rttiFields := TList<TRttiField>.Create;
  try
    for rttiField in self.GetFields() do begin
      if not isPublicOrPublished(rttiField) then
        continue;
      if rttiField.HasAttribute(IgnoreAttribute) then
        continue;
      rttiFields.Add(rttiField);
    end;
    exit(rttiFields.ToArray);
  finally
    rttiFields.Free;
  end;
end;

end.

