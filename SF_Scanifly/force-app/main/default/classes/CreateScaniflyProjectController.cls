public with sharing class CreateScaniflyProjectController {
    private ApexPages.StandardController standardController;
    public CreateScaniflyProjectController(ApexPages.StandardController controller) {
        standardController = controller;
    }

    public PageReference createScaniflyProject() {
        Id recordId = standardController.getId();
        Account account = (Account)standardController.getRecord();
        return null;
    }
}