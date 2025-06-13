unit JSONMapper.ClassFieldHelper;

interface

uses
  System.Rtti,
  System.TypInfo;

  function isSimpleDatatype(rttiField: TRttiField): boolean;
  function isPublicOrPublished(rttiField: TRttiField): boolean;

implementation

function isSimpleDatatype(rttiField: TRttiField): boolean;
begin
  case rttiField.FieldType.TypeKind of
    tkInteger,
    tkInt64,
    tkFloat,
    tkChar,
    tkWChar,
    tkString,
    tkLString,
    tkWString,
    tkUString,
    tkVariant: begin
      exit(true);
    end
    else begin
      exit(false);
    end;
  end;
end;

function isPublicOrPublished(rttiField: TRttiField): boolean;
begin
  exit(rttiField.Visibility in [mvPublic, mvPublished]);
end;

end.
