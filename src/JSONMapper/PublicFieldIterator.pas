unit PublicFieldIterator;

interface

uses
  {$IF USE_ATTRIBUTE_HELPER}
  AttributeHelper,
  {$ENDIF}
  System.Rtti,
  JSONMapper.ClassFieldHelper,
  JSONMapper.Attributes;

type
  TRttiInstanceTypeHelper = class helper for TRttiInstanceType
    function GetPublicFields(): TArray<TRttiField>;
  end;

  TRttiRecordTypeHelper = class helper for TRttiRecordType
    function GetPublicFields(): TArray<TRttiField>;
  end;

implementation

{ TRttiInstanceTypeHelper }

function TRttiInstanceTypeHelper.GetPublicFields(): TArray<TRttiField>;
var
  rttiFields: TArray<TRttiField>;
  rttiField: TRttiField;
begin
  SetLength(rttiFields, 0);
  for rttiField in self.GetFields() do begin
    if not isPublicOrPublished(rttiField)
    or rttiField.HasAttribute(IgnoreFieldAttribute) then begin
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
    or rttiField.HasAttribute(IgnoreFieldAttribute) then begin
      continue;
    end;

    SetLength(rttiFields, Length(rttiFields) + 1);
    rttiFields[High(rttiFields)] := rttiField;
  end;
  exit(rttiFields);
end;

end.
