codeunit 50100 AttachedDocuments
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::table, 1173, 'OnBeforeInsertAttachment', '', true, true)]
    local procedure OnBeforeImportWithFilter(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        ABSContainersetup: Record "ABS Container setup";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        InS: InStream;
        OutS: OutStream;
        tempBlob: Codeunit "Temp Blob";
        Filename: Text;
    begin
        ABSContainersetup.Get;
        Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
        ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
        //Copy from outstream to instream
        tempBlob.CreateOutStream(OutS);
        DocumentAttachment."Document Reference ID".ExportStream(OutS);
        tempBlob.CreateInStream(InS);
        Filename := DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension";
        ABSBlobClient.PutBlobBlockBlobStream(Filename, InS);
    end;

    [EventSubscriber(ObjectType::table, 1173, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure DeleteDocumentAttachment(var Rec: Record "Document Attachment"; RunTrigger: Boolean)
    var
        ABSBlobClient: codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        ABSContainersetup: Record "ABS Container setup";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Filename: Text;
    begin
        If RunTrigger then begin
            ABSContainersetup.Get;
            Authorization := StorageServiceAuthorization.CreateSharedKey(ABSContainersetup."Shared Access Key");
            ABSBlobClient.Initialize(ABSContainersetup."Account Name", ABSContainersetup."Container Name", Authorization);
            Filename := Rec."File Name" + '.' + Rec."File Extension";
            ABSBlobClient.DeleteBlob(Filename);
        end;
    end;

    [EventSubscriber(ObjectType::table, 1173, 'OnAfterInsertEvent', '', true, true)]
    local procedure DeleteMediaField(var Rec: Record "Document Attachment"; RunTrigger: Boolean)
    begin
        If RunTrigger then begin
            Clear(Rec."Document Reference ID");
            rec.Modify();
        end;
    end;
}