global class ScaniflyProjectDataSourceConnection extends DataSource.Connection {
    // private static String BASE_URL = 'https://api.portal.scanifly.com/api/v1';
    private static String BASE_URL = 'http://bailey.4twenty.us:3000/api/v1';
    private static String PROJECTS_ENDPOINT = '/projects';
    // private static String ACCESS_TOKEN = 'a4743a9a-8ce0-4e2c-aaec-96e92e0288f6'; // api.portal
    private static String ACCESS_TOKEN = 'e9243688-0fe4-4c7f-9e94-4d87d1818bb9'; // bailey

    global ScaniflyProjectDataSourceConnection(DataSource.ConnectionParams connectionParams) {
    }

    public override List<DataSource.Table> sync() {
        List<DataSource.Table> tables =  new List<DataSource.Table>();

        List<DataSource.Column> projectColumns = new List<DataSource.Column>();
        projectColumns.add(DataSource.Column.text('ExternalId', 255));
        projectColumns.add(DataSource.Column.url('DisplayUrl'));
        projectColumns.add(DataSource.Column.indirectLookup('id', 'Account', 'ScaniflyProjectID__c'));

        projectColumns.add(DataSource.Column.text('name', 255));
        projectColumns.add(DataSource.Column.text('status', 255));
        projectColumns.add(DataSource.Column.text('longitude', 255));
        projectColumns.add(DataSource.Column.text('latitude', 255));
        projectColumns.add(DataSource.Column.text('ownerFirstName', 255));
        projectColumns.add(DataSource.Column.text('ownerLastName', 255));
        projectColumns.add(DataSource.Column.text('ownerPhone', 255));
        projectColumns.add(DataSource.Column.text('ownerEmail', 255));
        projectColumns.add(DataSource.Column.text('address', 255));
        projectColumns.add(DataSource.Column.text('createdAt', 255));
        projectColumns.add(DataSource.Column.text('updatedAt', 255));
        projectColumns.add(DataSource.Column.text('type', 255));

        DataSource.Table projectTable = new DataSource.Table();
        projectTable.labelSingular = 'ScaniflyProject';
        projectTable.labelPlural = 'ScaniflyProjects';
        projectTable.description = 'A list of Scanifly projects';
        projectTable.name = 'ScaniflyProject';
        projectTable.nameColumn = 'ScaniflyProject';
        projectTable.columns = projectColumns;
        tables.add(projectTable);

        return tables;
    }

    override global DataSource.TableResult query(DataSource.QueryContext context) {
        String table = context.tableSelection.tableSelected;
        return DataSource.TableResult.get(context, DataSource.QueryUtils.process(context, getRows(table)));
    }

    private List<Map<String,Object>> getRows(String table) {
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        String url = BASE_URL;
        if(table.equals('ScaniflyProject')) {
            url += PROJECTS_ENDPOINT;
        }
        url +=  '?access_token=' + ACCESS_TOKEN;

        HttpResponse response = makeGetCallout(url);
        Map<String,Object> responseObject = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        List<Object> items = (List<Object>)responseObject.get('items');
        for(Object project : items) {
            rows.add(populateProjectRow((Map<String,Object>)project));
        }
        return rows;
    }

    private static HttpResponse makeGetCallout(String url) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('accept', 'application/json');
        return (new Http()).send(req);
    }

    private Map<String,Object> populateProjectRow(Map<String,Object> project) {
        Map<String,Object> row = new Map<String,Object>();
        
        String id = string.valueOf(project.get('id'));
        row.put('ExternalId', id);
        row.put('id', id);
        
        String displayUrl = BASE_URL + PROJECTS_ENDPOINT + '/' + id + '?access_token=' + ACCESS_TOKEN;
        row.put('DisplayUrl', displayUrl);

        row.put('status', string.valueOf(project.get('status')));

        Map<String,Object> geolocation = (Map<String,Object>)project.get('geolocation');
        row.put('latitude', string.valueOf(geolocation.get('latitude')));
        row.put('longitude', string.valueOf(geolocation.get('longitude')));

        Map<String,Object> ownerDetails = (Map<String,Object>)project.get('ownerDetails');
        row.put('ownerFirstName', string.valueOf(ownerDetails.get('firstName')));
        row.put('ownerLastName', string.valueOf(ownerDetails.get('lastName')));
        row.put('ownerEmail', string.valueOf(ownerDetails.get('email')));
        row.put('ownerPhone', string.valueOf(ownerDetails.get('phone')));

        row.put('name', string.valueOf(project.get('name')));
        row.put('address', string.valueOf(project.get('address')));
        row.put('createdAt', string.valueOf(project.get('createdAt')));
        row.put('updatedAt', string.valueOf(project.get('updatedAt')));
        row.put('type', string.valueOf(project.get('type')));
        return row;
    }
}