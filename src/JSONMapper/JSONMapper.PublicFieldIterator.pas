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
  JSONMapper.Attributes;

type
  TRttiInstanceTypeHelper = class helper for TRttiInstanceType
    function GetPublicFields(): TArray<TRttiField>;
  end;

  TRttiRecordTypeHelper = class helper for TRttiRecordType
    function GetPublicFields(): TArray<TRttiField>;
  end;

implementation

function isPublicOrPublished(rttiField: TRttiField): boolean;
begin
  exit(rttiField.Visibility in [mvPublic, mvPublished]);
end;

{ TRttiInstanceTypeHelper }

function TRttiInstanceTypeHelper.GetPublicFields(): TArray<TRttiField>;
var
  rttiFields: TArray<TRttiField>;
  rttiField: TRttiField;
begin
  SetLength(rttiFields, 0);
  for rttiField in self.GetFields() do begin
    if not isPublicOrPublished(rttiField)
    or rttiField.HasAttribute(IgnoreAttribute) then begin
      continue;
    end;

    SetLength(rttiFields, Length(rttiFields) + 1);
    rttiFields[High(rttiFields)] := rttiField;
  end;
  exit(rttiFields);
end;

{ TRttiRecordTypeHelper }

function TRttiRecordTypeHelper.GetPublicFields(): TArray<TRttiField>;
var
  rttiFields: TArray<TRttiField>;
  rttiField: TRttiField;
begin
  SetLength(rttiFields, 0);
  for rttiField in self.GetFields() do begin
    if not isPublicOrPublished(rttiField)
    or rttiField.HasAttribute(IgnoreAttribute) then begin
      continue;
    end;

    SetLength(rttiFields, Length(rttiFields) + 1);
    rttiFields[High(rttiFields)] := rttiField;
  end;
  exit(rttiFields);
end;

end.
