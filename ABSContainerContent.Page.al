page 50101 "ABS Container Content"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "ABS Container Content";
    Caption = 'ABS Container Content';
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(FullName; rec."Full Name")
                {
                    ApplicationArea = All;
                }
                field(ContentType; rec."Content Type")
                {
                    ApplicationArea = All;
                }
                field(LastModified; rec."Last Modified")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Download)
            {
                ApplicationArea = All;
                Caption = 'Download';

                trigger OnAction();
                begin
                    ABSBlobClient.GetBlobAsFile(rec."Full Name");
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';

                trigger OnAction();
                begin
                    ABSBlobClient.DeleteBlob(rec."Full Name");
                end;
            }
            action(Upload)
            {
                ApplicationArea = All;
                Caption = 'Upload';

                trigger OnAction();
                var
                    SourceStream: InStream;
                begin
                    PutBlobBlockBlobUI();
                    ABSBlobClient.ListBlobs(rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ABSContainersetup.Get;
        Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
        ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);

        Response := ABSBlobClient.ListBlobs(rec);

        If Response.GetError() <> '' then
            message(format(Response.GetError()));

    end;

    //Because of error in codeunit 9051 "ABS Client Impl." procedure PutBlobBlockBlobUI
    procedure PutBlobBlockBlobUI(): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Filename: Text;
        SourceStream: InStream;
        OptionalParameters: Codeunit "ABS Optional Parameters";
    begin
        if UploadIntoStream('Choose file', '', 'All files (*.*)|*.*', Filename, SourceStream) then
            OperationResponse := ABSBlobClient.PutBlobBlockBlobStream(Filename, SourceStream, OptionalParameters);

        exit(OperationResponse);
    end;

    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        ABSContainerContent: Record "ABS Container Content";
        ABSContainersetup: Record "ABS Container setup";
}