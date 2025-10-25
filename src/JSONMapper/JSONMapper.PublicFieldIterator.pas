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
    function GetPublicDataMembers(): TArray<TRttiDataMember>;
  end;

  TRttiRecordTypeHelper = class helper for TRttiRecordType
    function GetPublicDataMembers(): TArray<TRttiDataMember>;
  end;

implementation

function isPublicOrPublished(rttiDataMember: TRttiDataMember): boolean;
begin
  exit(rttiDataMember.Visibility in [mvPublic, mvPublished]);
end;

{ TRttiInstanceTypeHelper }

function TRttiInstanceTypeHelper.GetPublicDataMembers(): TArray<TRttiDataMember>;
var
  rttiDataMembers: TList<TRttiDataMember>;
  rttiDataMember: TRttiDataMember;
begin
  rttiDataMembers := TList<TRttiDataMember>.Create;
  try
    for rttiDataMember in self.GetFields() do begin
      if not isPublicOrPublished(rttiDataMember) then
        continue;
      if rttiDataMember.HasAttribute(IgnoreAttribute) then
        continue;
      rttiDataMembers.Add(rttiDataMember);
    end;

    for rttiDataMember in self.GetProperties() do begin
      if not isPublicOrPublished(rttiDataMember) then
        continue;
      if rttiDataMember.HasAttribute(IgnoreAttribute) then
        continue;
      rttiDataMembers.Add(rttiDataMember);
    end;

    exit(rttiDataMembers.ToArray);
  finally
    rttiDataMembers.Free;
  end;
end;

{ TRttiRecordTypeHelper }

function TRttiRecordTypeHelper.GetPublicDataMembers(): TArray<TRttiDataMember>;
var
  rttiDataMembers: TList<TRttiDataMember>;
  rttiDataMember: TRttiDataMember;
begin
  rttiDataMembers := TList<TRttiDataMember>.Create;
  try
    for rttiDataMember in self.GetFields() do begin
      if not isPublicOrPublished(rttiDataMember) then
        continue;
      if rttiDataMember.HasAttribute(IgnoreAttribute) then
        continue;
      rttiDataMembers.Add(rttiDataMember);
    end;

    // somehow doesn't work for records
    for rttiDataMember in self.GetProperties() do begin
      if not isPublicOrPublished(rttiDataMember) then
        continue;
      if rttiDataMember.HasAttribute(IgnoreAttribute) then
        continue;
      rttiDataMembers.Add(rttiDataMember);
    end;

    exit(rttiDataMembers.ToArray);
  finally
    rttiDataMembers.Free;
  end;
end;

end.
