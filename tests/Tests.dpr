program Tests;

{$IFNDEF TESTINSIGHT}
  {$APPTYPE CONSOLE}
{$ENDIF}

{$STRONGLINKTYPES ON}

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  {$IFDEF USE_ATTRIBUTE_HELPER}
  JSONMapper.AttributeHelper in '..\src\JSONMapper\JSONMapper.AttributeHelper.pas',
  {$ENDIF }
  JSONMapper in '..\src\JSONMapper\JSONMapper.pas',
  JSONMapper.Exceptions in '..\src\JSONMapper\JSONMapper.Exceptions.pas',
  JSONMapper.Attributes in '..\src\JSONMapper\JSONMapper.Attributes.pas',
  JSONMapper.ListHelper in '..\src\JSONMapper\JSONMapper.ListHelper.pas',
  JSONMapper.DateTimeFormatter in '..\src\JSONMapper\JSONMapper.DateTimeFormatter.pas',
  JSONMapper.Settings in '..\src\JSONMapper\JSONMapper.Settings.pas',
  JSONMapper.PublicFieldIterator in '..\src\JSONMapper\JSONMapper.PublicFieldIterator.pas',
  QueryMapper in '..\src\QueryMapper\QueryMapper.pas',
  QueryMapper.Attributes in '..\src\QueryMapper\QueryMapper.Attributes.pas',
  QueryMapper.DatasetEnumerator in '..\src\QueryMapper\QueryMapper.DatasetEnumerator.pas',
  QueryMapper.RowMapper in '..\src\QueryMapper\QueryMapper.RowMapper.pas',
  QueryMapper.Exceptions in '..\src\QueryMapper\QueryMapper.Exceptions.pas',
  CustomMapper in '..\src\shared\CustomMapper.pas',
  ObjectToJSON._Object in 'src\JSONMapper\ObjectToJSON\ObjectToJSON._Object.pas',
  ObjectToJSON.DateTime in 'src\JSONMapper\ObjectToJSON\ObjectToJSON.DateTime.pas',
  ObjectToJSON.IgnoreAttribute in 'src\JSONMapper\ObjectToJSON\ObjectToJSON.IgnoreAttribute.pas',
  ObjectToJSON.List in 'src\JSONMapper\ObjectToJSON\ObjectToJSON.List.pas',
  ObjectToJSON._Record in 'src\JSONMapper\ObjectToJSON\ObjectToJSON._Record.pas',
  ObjectToJSON.Arrays in 'src\JSONMapper\ObjectToJSON\ObjectToJSON.Arrays.pas',
  ObjectToJSON.Variant in 'src\JSONMapper\ObjectToJSON\ObjectToJSON.Variant.pas',
  ObjectToJSON.JSONKeyAttribute in 'src\JSONMapper\ObjectToJSON\ObjectToJSON.JSONKeyAttribute.pas',
  JSONToObject._Object in 'src\JSONMapper\JSONToObject\JSONToObject._Object.pas',
  JSONToObject._Record in 'src\JSONMapper\JSONToObject\JSONToObject._Record.pas',
  JSONToObject.DateTime in 'src\JSONMapper\JSONToObject\JSONToObject.DateTime.pas',
  JSONToObject.Variant in 'src\JSONMapper\JSONToObject\JSONToObject.Variant.pas',
  JSONToObject.List in 'src\JSONMapper\JSONToObject\JSONToObject.List.pas',
  JSONToObject.JSONKeyAttribute in 'src\JSONMapper\JSONToObject\JSONToObject.JSONKeyAttribute.pas',
  Test.CustomMapper.Enum in 'src\CustomMapper\Test.CustomMapper.Enum.pas',
  Test.QueryMapper.BasicMapping in 'src\QueryMapper\Test.QueryMapper.BasicMapping.pas',
  Test.QueryMapper.GetOne in 'src\QueryMapper\Test.QueryMapper.GetOne.pas',
  Test.QueryMapper.Count in 'src\QueryMapper\Test.QueryMapper.Count.pas',
  Nullable in '..\src\shared\Nullable.pas',
  Nullable.Test in 'src\Nullable\Nullable.Test.pas',
  Test.CustomMapper.UUIDType in 'src\CustomMapper\Test.CustomMapper.UUIDType.pas';

//
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
  ReportMemoryLeaksOnShutdown := true;
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
