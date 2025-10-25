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
  JSONMapper.CustomMapping in '..\src\JSONMapper\JSONMapper.CustomMapping.pas',
  JSONMapper.Settings in '..\src\JSONMapper\JSONMapper.Settings.pas',
  JSONMapper.PublicFieldIterator in '..\src\JSONMapper\JSONMapper.PublicFieldIterator.pas',
  ObjectToJSON._Object in 'JSONMapper\ObjectToJSON\ObjectToJSON._Object.pas',
  ObjectToJSON.DateTime in 'JSONMapper\ObjectToJSON\ObjectToJSON.DateTime.pas',
  ObjectToJSON.IgnoreAttribute in 'JSONMapper\ObjectToJSON\ObjectToJSON.IgnoreAttribute.pas',
  ObjectToJSON.List in 'JSONMapper\ObjectToJSON\ObjectToJSON.List.pas',
  ObjectToJSON._Record in 'JSONMapper\ObjectToJSON\ObjectToJSON._Record.pas',
  ObjectToJSON.Arrays in 'JSONMapper\ObjectToJSON\ObjectToJSON.Arrays.pas',
  ObjectToJSON.Variant in 'JSONMapper\ObjectToJSON\ObjectToJSON.Variant.pas',
  JSONToObject._Object in 'JSONMapper\JSONToObject\JSONToObject._Object.pas',
  JSONToObject._Record in 'JSONMapper\JSONToObject\JSONToObject._Record.pas',
  JSONToObject.DateTime in 'JSONMapper\JSONToObject\JSONToObject.DateTime.pas',
  JSONToObject.Variant in 'JSONMapper\JSONToObject\JSONToObject.Variant.pas',
  JSONToObject.List in 'JSONMapper\JSONToObject\JSONToObject.List.pas',
  Test.CustomMapping in 'JSONMapper\Test.CustomMapping.pas',
  QueryMapper in '..\src\QueryMapper\QueryMapper.pas',
  QueryMapper.Attributes in '..\src\QueryMapper\QueryMapper.Attributes.pas',
  QueryMapper.DatasetEnumerator in '..\src\QueryMapper\QueryMapper.DatasetEnumerator.pas',
  QueryMapper.RowMapper in '..\src\QueryMapper\QueryMapper.RowMapper.pas',
  QueryMapper.Exceptions in '..\src\QueryMapper\QueryMapper.Exceptions.pas',
  QueryMapper.Test in 'QueryMapper\QueryMapper.Test.pas',
  Nullable in '..\src\Nullable\Nullable.pas',
  Nullable.Test in 'Nullable\Nullable.Test.pas';

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
