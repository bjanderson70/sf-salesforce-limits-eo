/**
 * Copyright (c) 2016-2020, Bill Anderson All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *
 *   * Neither the name of Bill Anderson nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * @File Name          : SalesforceLimitsDataSourceConnection.cls
 * @Description        : External Object for Salesforce Limits.
 *                       Supports Anonymous and Named Credentials
 * @Author             : Bill Anderson
 * @Group              : External Data Source
 **/

global without sharing class SalesforceLimitsDataSourceConnection extends DataSource.Connection
{
    //////////////////////////////////////////////////////////////////////////////////
    // Data Members
    //
    //////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    static final string SERVICE_VERSION = '48.0';
    @TestVisible
    static final string NAMED_CRED_ORG_URL = 'callout:Salesforce_Limits';
    @TestVisible
    static final String DISPLAY_URL= URL.getSalesforceBaseUrl().toExternalForm();
    @TestVisible
    static final boolean DEBUG_LOG = true;
    @TestVisible
    static final boolean isTesting = Test.isRunningTest();
     

    /*
     * Our current field-names
     */
    @TestVisible
    static final string FIELDNAME_NAME= 'Name';
    @TestVisible
    static final string FIELDNAME_MAX= 'Max';
    @TestVisible
    static final string FIELDNAME_RATIO= 'Ratio';
    @TestVisible
    static final string FIELDNAME_REMAINING= 'Remaining';
    @TestVisible
    static final string FIELDNAME_EXTERNAL_ID= 'ExternalId';
    @TestVisible
    static final string FIELDNAME_ID= 'Id';
    @TestVisible
    static final string FIELDNAME_DISPLAY_URL= 'DisplayUrl';

    @TestVisible
    static final Set<String> fieldNameSet = new Set<String> {
        FIELDNAME_NAME
        ,FIELDNAME_MAX
        ,FIELDNAME_RATIO
        ,FIELDNAME_REMAINING
        ,FIELDNAME_EXTERNAL_ID
        ,FIELDNAME_ID
        ,FIELDNAME_DISPLAY_URL
    };
    @TestVisible
    static final string DESCRIPTION = 'Salesforce Limits';
    @TestVisible
    static final string LABEL_SINGULAR = 'Salesforce Limit';
    @TestVisible
    static final string TABLE_NAME = 'SalesforceLimits';
    /**
     * map filter to string
     **/
    @TestVisible
    static final Map<DataSource.FilterType, integer> filterMap = new Map<DataSource.FilterType, integer> {
        DataSource.FilterType.AND_ => 0,
        DataSource.FilterType.CONTAINS => 0,
        DataSource.FilterType.ENDS_WITH => 0,
        DataSource.FilterType.EQUALS => 0,
        DataSource.FilterType.GREATER_THAN => -1,
        DataSource.FilterType.GREATER_THAN_OR_EQUAL_TO => -1,
        DataSource.FilterType.LESS_THAN => 1,
        DataSource.FilterType.LESS_THAN_OR_EQUAL_TO => 1,
        DataSource.FilterType.LIKE_ => 0,
        DataSource.FilterType.NOT_ => 0,
        DataSource.FilterType.NOT_EQUALS => 0,
        DataSource.FilterType.OR_ => 0,
        DataSource.FilterType.STARTS_WITH => 0
    };

    @TestVisible
    static final List<String> testLogMessages = SalesforceLimitsDataSourceConnection.isTesting ? new List<String>() : null;

    /**
     * Results from our REST API call
     */
    public class LimitResults {
        /*
         * DTO Data Members
         */
        public decimal max, remaining;
        public decimal ratio;
        public string name,externalId,displayUrl;
        /*
         * ctor
         */
        public LimitResults(string theName, integer theMax, integer theRemaining){
            this.name = theName;
            this.externalId = string.valueOf( Math.abs (this.name.hashCode()));
            this.displayUrl =  DISPLAY_URL +'/' + this.name;
            this.max = theMax;
            this.remaining = theRemaining;
            // percent remaining
            this.ratio =  ((1-(this.remaining/this.max))*100.0).setScale(2);

        }
    } // end of LimitResults

    /*
     * Http Salesforce Limit Response
     */
    public class HttpSFLimitResponse {
        integer Max;
        integer Remaining;
    }
    /*
     * Http Salesforce Version Response
     */
    public class HttpVersionResponse
    {
        public String label;
        public String url;
        public String version;
    }
    /*
     * List Wrapper - need ability to sort list
     */
    public class LimitResultsWrapper implements Comparable {
        ////////////////////////////////////////////////////////////////////////////////
        // Data Members
        ////////////////////////////////////////////////////////////////////////////////
        /*
         * Data Members for DTO (sort wrapper)
         */
        public LimitResults lresult;

        ////////////////////////////////////////////////////////////////////////////////
        // Ctors
        ////////////////////////////////////////////////////////////////////////////////
        /*
         * Ctor
         */
        public LimitResultsWrapper(LimitResults lr) {
            lresult = lr;
            this.sortBy = FIELDNAME_NAME;
            this.sortAscending=true;
        }// end of ctor
        ////////////////////////////////////////////////////////////////////////////////
        // Public Properties
        ////////////////////////////////////////////////////////////////////////////////
        /*
         * Properties (getters)
         */
        public decimal max { get { return lresult.max;}}
        public decimal remaining { get { return lresult.remaining;}}
        public decimal ratio { get { return lresult.ratio;}}
        public String name { get { return lresult.name;}}
        public String externalId { get { return lresult.externalId;  }}
        public String displayUrl { get { return lresult.displayUrl;  }}

        /*
         * Sort by Name
         */
        @TestVisible
        public string sortBy {
            get;
            private set;
        }
        /*
         * assending order (defaults to true)
         */
        @TestVisible
        public boolean sortAscending {
            get;
            private set;
        }
        ////////////////////////////////////////////////////////////////////////////////
        // Public Methods
        ////////////////////////////////////////////////////////////////////////////////
        /**
         * getBy
         * @description get value by name
         * @param  index index name
         * @return value associate with name/index
         */
        public Object getBy(string index){
            Object result='';
            if ( index == FIELDNAME_MAX) {
                result= this.max;
            } else if ( index ==  FIELDNAME_NAME) {
                result= this.name;
            }else if ( index == FIELDNAME_RATIO) {
                result= this.ratio;
            }else if ( index ==  FIELDNAME_REMAINING) {
                result= this.remaining;
            } else if ( index == FIELDNAME_EXTERNAL_ID) {
                result= this.externalId;
            } else if ( index == FIELDNAME_DISPLAY_URL) {
                result =this.displayUrl;
            }

            return result;
        }
        /**
         * compareTo
         * @description use to compare current object to another
         * @param  compareTo Limit value
         * @return 0 , if equal, 1 if > and -1 <
         */
        public Integer compareTo(Object compareTo) {
            // Cast argument to LimitResultsWrapper
            LimitResultsWrapper compareToLimit = (LimitResultsWrapper)compareTo;

            // bogus data
            if ( compareToLimit == null ) {
                return -1;
            }

            String index = this.sortBy;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = this.compareValues(index
                                                     , this.getBy(index)
                                                     , compareToLimit.getBy(index));

            // if descending, flip it
            if ( this.sortAscending == false
                 && returnValue != 0) {
                returnValue *= -1;
            }

            return returnValue;
        } // end of compareTo
        /*
         * compareValues
         * @description compare element and determine order (0 ==, 1 >, -1 <)
         * @return (0 ==, 1 >, -1 <)
         */
        @TestVisible
        private integer compareValues(string name
                                      , object lvalue
                                      , object rvalue){

            integer returnValue=0;
            // is it a string type
            if ( name == FIELDNAME_NAME
                 || name == FIELDNAME_EXTERNAL_ID
                 || name == FIELDNAME_DISPLAY_URL ) {
                if ((String)lvalue > (String)rvalue) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if ((String)lvalue < (String)rvalue) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }

            } else {
                // it is decimal values
                if ((Decimal)lvalue > (Decimal)rvalue) {
                    // Set return value to a positive value.
                    returnValue = 1;
                } else if ((Decimal)lvalue < (Decimal)rvalue) {
                    // Set return value to a negative value.
                    returnValue = -1;
                }

            }

            return returnValue;
        }// end of sortByValue

    }     // end of LimitResultsWrapper

    //////////////////////////////////////////////////////////////////////////////////
    // Ctors
    //
    //////////////////////////////////////////////////////////////////////////////////
    /**
     * default ctor
     */
    global SalesforceLimitsDataSourceConnection() {
        this(null);
    }      // end of ctor
    /**
     * ctor
     */
    global SalesforceLimitsDataSourceConnection(DataSource.ConnectionParams connectionParams) {
        this.theLimits=null;
        this.limitWhere='';
        this.limitWhereValue='';
        this.limitAscending=true;
        this.limitOrderBy=FIELDNAME_NAME;
        this.limitOffset=0;
        this.limitFilterType=DataSource.FilterType.EQUALS;
        this.limitIdentityType =  connectionParams != null ? connectionParams.principalType :  DataSource.IdentityType.ANONYMOUS;

    }    // end of ctor


    //////////////////////////////////////////////////////////////////////////////////
    // Public Properties
    //
    //////////////////////////////////////////////////////////////////////////////////

    /*
     * Used this global properties to understand query parameters for processing later
     */
    @TestVisible
    public String limitOrderBy { get; private set;}
    @TestVisible
    public boolean limitAscending { get; private set;}
    @TestVisible
    public integer limitOffset { get; private set;}
    @TestVisible
    public String limitWhere { get; private set;}
    @TestVisible
    public String limitWhereValue { get; private set; }
    @TestVisible
    public DataSource.IdentityType limitIdentityType {get; private set;}
    @TestVisible
    public DataSource.FilterType limitFilterType { get; private set;}

    /*
     * holds the results from the REST API
     */
    @TestVisible
    public List<LimitResultsWrapper> theLimits {
        get;
        private set;
    }
    //////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    //
    //////////////////////////////////////////////////////////////////////////////////
    /**
     * log
     * @description log exception to debug log
     * @param  excp excp description
     */
    public static void log(Exception excp) {
        if ( excp != null ) {
            SalesforceLimitsDataSourceConnection.log( ' [EXCEPTION-Message] '+ excp.getMessage(),true);
            SalesforceLimitsDataSourceConnection.log( ' [EXCEPTION-StackTrace] '+ excp.getStackTraceString(),true);
        }
    }    // end of log

    /**
     * log
     * @description log messages to debug log
     *
     * @param  message
     */
    public static void log(String message) {
        SalesforceLimitsDataSourceConnection.log(message,SalesforceLimitsDataSourceConnection.DEBUG_LOG);
    }    // end of log
    /**
     * log
     * @description log messages to debug log
     *
     * @param  message
     */
    public static void log(String message, boolean loggerOn) {
        if ( message != null && loggerOn ) {
            String msg = '+++ SalesforceLimitsDataSourceConnection:' + message;
            // for unit testing
            if ( SalesforceLimitsDataSourceConnection.isTesting ) {
                testLogMessages.add(msg);
            }
            system.debug(msg);
        }
    }// end of log

    /*
     * Sync with Salesforce
     */
    override global List<DataSource.Table> sync()
    {
        List<DataSource.Table> tables = new List<DataSource.Table>();
        List<Datasource.Column> columns = new List<Datasource.Column>();

        columns.add(DataSource.Column.url(FIELDNAME_DISPLAY_URL));
        columns.add(DataSource.Column.text(FIELDNAME_EXTERNAL_ID, 255));
        columns.add(DataSource.Column.text(FIELDNAME_NAME,255));
        columns.add(DataSource.Column.integer(FIELDNAME_MAX,18));
        columns.add(DataSource.Column.integer(FIELDNAME_REMAINING, 18));
        columns.add(DataSource.Column.number(FIELDNAME_RATIO, 18,2));

        Datasource.Table acTable = DataSource.Table.get(TABLE_NAME, FIELDNAME_NAME, columns);
        acTable.description = DESCRIPTION;
        acTable.labelSingular = LABEL_SINGULAR;
        acTable.labelPlural = DESCRIPTION;

        tables.add(acTable);

        return tables;
    }    // end of sync
    /*
     *  Query on external object
     */
    override global DataSource.TableResult query(DataSource.QueryContext context) {

        try {

            // log('+++++ query.context:'+JSON.serialize(context.tableSelection) + '++++');

            /*
             * get all the user's query information
             */
            this.limitOffset = context.offset;
            // this causes an exception when running unit tests; will ignore doing unit testing
            if ( !SalesforceLimitsDataSourceConnection.isTesting ) {
                this.getFilterSoqlTerm(context.tableSelection.filter);
            }
            this.getOrderSoqlTerm(context.tableSelection.order);

            if (context.tableSelection.columnsSelected.size() == 1 &&
                context.tableSelection.columnsSelected.get(0).aggregation ==
                DataSource.QueryAggregation.COUNT)
            {
                List<Map<String, Object> > countResponse = new List<Map<String, Object> >();
                Map<String, Object> countRow = new Map<String, Object>();
                integer totalRows  = this.salesforceApexLimitsCallout().size();

                countRow.put(context.tableSelection.columnsSelected.get(0).columnName, totalRows);
                countResponse.add(countRow);
                return DataSource.TableResult.get(context,countResponse);
            }

            /*
             * Note: Performance is 2*O(n) as we need to sort. Because this is
             * a very small list; improvements were not done
             */
            List<Map<String,Object> > rowsList = new List<Map<String, Object> >();
            // all data
            List<LimitResultsWrapper> results = this.salesforceApexLimitsCallout();
            // this is the filterd (to be sorted) list
            List<LimitResultsWrapper> filterResults = this.filterAllResultsByWhere(results);

            // sort according to users request, if any
            if ( string.isNotBlank(this.limitOrderBy) ) {
                filterResults.sort();
            }

            integer startAt = 0;
            Map<String, Object> rowResults=null;
            Boolean addExternal = false;

            // iterate over the list, starting with offset
            for (LimitResultsWrapper lresult: filterResults ) {
                if ( startAt >= this.limitOffset ) {
                    rowResults = new Map<String, Object>();
                    // iterate over the columns
                    for(Datasource.ColumnSelection col: context.tableSelection.columnsSelected) {
                        rowResults.put (col.columnName,lresult.getBy(col.columnName));
                        // check for external id
                        if ( addExternal == false && col.columnName==FIELDNAME_EXTERNAL_ID) {
                            addExternal=true;
                        }
                    }

                    // always add external id column
                    if ( addExternal == false) {
                        rowResults.put (FIELDNAME_EXTERNAL_ID,lresult.getBy(FIELDNAME_EXTERNAL_ID));
                    }
                    rowsList.add(rowResults);
                    rowResults=null;
                    addExternal=false;
                } // end if
                startAt++;
            } // end for

            Datasource.TableResult queryResult = DataSource.TableResult.get(context,rowsList);
            queryResult.totalSize = rowsList.size();

            return queryResult;
        }catch (Exception excp) {
            SalesforceLimitsDataSourceConnection.log(excp);
        }
        return null;

    }    // end of query

    /*
     * search request
     */
    override global List<DataSource.TableResult> search(DataSource.SearchContext context) {
        return DataSource.SearchUtils.searchByName(context, this);
    }    // end of search

    //////////////////////////////////////////////////////////////////////////////////
    // Private Methods
    //
    //////////////////////////////////////////////////////////////////////////////////

    /**
     * filterAllResultsByWhere
     * @description based on query, determine the results to return by the where clause
     * @param  results current list
     * @return collection of filtered items
     */
    @TestVisible
    private List<LimitResultsWrapper> filterAllResultsByWhere( List<LimitResultsWrapper> results){

        // this is the filterd (sorted) list
        List<LimitResultsWrapper> filterResults = new List<LimitResultsWrapper>();
        // go ahead and do all the relevant checks ( no need to do O(n) times)
        Boolean isEmptyWhere =  string.isEmpty(this.limitWhere)
        , addItem = isEmptyWhere || fieldNameSet.contains(this.limitWhere)
        , hasValue = !isEmptyWhere && string.isNotEmpty(this.limitWhereValue);
        // the expected result from a compare ( -1,1,0)
        Integer compareTo = filterMap.get(this.limitFilterType);

        // determine what gets displayed
        for (LimitResultsWrapper lresult: results ) {
            lresult.sortAscending = this.limitAscending;
            lresult.sortBy = this.limitOrderBy;

            // all data ? ( can only have one where parameter)
            if ( addItem ) {
                if ( hasValue ) {
                    // here we filter a bit ( not ALL values)
                    if ( compareTo==lresult.compareValues(this.limitWhere
                                                          , this.convertToRightType(this.limitWhere,this.limitWhereValue)
                                                          , lresult.getBy(this.limitWhere))) {
                        filterResults.add(lresult);
                    }
                } else {
                    filterResults.add(lresult);
                }
            }
        }
        return filterResults;
    }// end of filterAllResultsByWhere
    /**
     * convertToRightType
     * @description convert data type to excepted type
     * @param  name  name of item
     * @param  value value of item
     * @return right type ( string or decimal)
     */
    @TestVisible
    private Object convertToRightType(String name, String value)
    {
        Decimal result = 0;
        if ( name == FIELDNAME_NAME
             || name == FIELDNAME_EXTERNAL_ID
             || name == FIELDNAME_DISPLAY_URL ) {
            return value;
        }
        try {
            result= Decimal.valueOf(value);
        } catch (Exception excp) {}
        return result;

    }// end of convertToRightType
    /*
     * Get the filter term (WHERE params)
     */
    @TestVisible
    private void getFilterSoqlTerm(DataSource.Filter filter)
    {
        // **** WARNNING ****
        // Calling this during unit test causes a Salesforce Internal Error
        // even if BOTH connection and provide and been validated & synced!
        // Just setting the data members below causes an internal error. Bogus!
        //
        try  {

            this.limitWhereValue = '';
            this.limitWhere='';
            this.limitFilterType=DataSource.FilterType.EQUALS;

            if(filter !=null) {
                this.limitWhere = filter.columnName;
                this.limitWhereValue =  String.valueOf(filter.columnValue);
                this.limitFilterType=filter.type;
            }
        } catch (Exception excp) {
            SalesforceLimitsDataSourceConnection.log(excp);
        }
    }    // end of getFilterSoqlTerm

    /*
     * Determine user order
     */

    @TestVisible
    private void getOrderSoqlTerm(List<DataSource.Order> orders)
    {
        this.limitOrderBy=FIELDNAME_NAME;
        this.limitAscending=true;

        if(orders==null || orders.size()==0 ) {
            return;
        }

        for(DataSource.Order order: orders)
        {
            if(order==null) break;
            /* last one wins
             */
            this.limitOrderBy=order.columnName;
            this.limitAscending= order.direction == Datasource.OrderDirection.ASCENDING;
        }
    }     // end of getOrderSoqlTerm

    /**
     * salesforceApexLimitsCallout
     * @description go get the limits
     * @return collection of limits
     */
    @TestVisible
    private List<LimitResultsWrapper> salesforceApexLimitsCallout() {
        // any data
        if ( this.theLimits == null ) {
            this.theLimits = new List<LimitResultsWrapper>();
            // have we gotten the data already ???
        } else if ( this.theLimits.size() > 0 ) {
            return this.theLimits;
        }

        try
        {
            DataSource.IdentityType iType = this.limitIdentityType;
            // one API call ( did not want to hard code version for prod)
            String version=SERVICE_VERSION;
            // if we are testing, the two API calls makes mocking more challenging
            if ( !SalesforceLimitsDataSourceConnection.isTesting ) {
                version=SalesforceLimitsDataSourceConnection.getLatestAPIVersion(iType);
            }
            /*
             * Here (when testing) the mock will come into play [the version will be pre-defined]
             */
            // format url
            String endpoint = SalesforceLimitsDataSourceConnection.makeEndpoint (iType,'/services/data/v'+version +'/limits');
            // make request
            HttpRequest req = SalesforceLimitsDataSourceConnection.createHttpRequest(iType,endpoint);
            // callout
            String result = SalesforceLimitsDataSourceConnection.makeCallout(req);

            if( result != null ) {
                HttpSFLimitResponse resp=null;
                // map json
                Map<String,HttpSFLimitResponse> rawObj = (Map<String,HttpSFLimitResponse>) System.JSON.deserialize(result
                                                                                                                   , Map<String,HttpSFLimitResponse>.class);
                // iterate over data
                for (String key : rawObj.keyset() )
                {
                    resp = (HttpSFLimitResponse)rawObj.get(key);
                    this.theLimits.add( new LimitResultsWrapper(  new LimitResults(key
                                                                                   ,resp.Max
                                                                                   ,resp.Remaining)));
                }
            }     // end if
        } catch(Exception excp) {
            SalesforceLimitsDataSourceConnection.log(excp);
        }

        return this.theLimits;
    }     // end of salesforceApexLimitsCallout
    /**
     * makeEndpoint
     * @description make an endpoint base don identity-type
     * @param  itype identity type
     * @param  endpt endpoint
     * @return correct format of the URL
     */
    @TestVisible
    private static string makeEndpoint(DataSource.IdentityType itype, String endpt){
        String domainUrl = itype == DataSource.IdentityType.ANONYMOUS ? DISPLAY_URL : NAMED_CRED_ORG_URL;
        //  url
        return domainUrl + endpt;
    }     // end of makeEndpoint
    /*
     * Get the latest API Version
     */
    @TestVisible
    private static String getLatestAPIVersion(DataSource.IdentityType itype)
    {
        // set the default
        String latestVersion = SERVICE_VERSION;

        final String endpoint = SalesforceLimitsDataSourceConnection.makeEndpoint(itype,'/services/data');

        try
        {
            HttpRequest req = SalesforceLimitsDataSourceConnection.createHttpRequest(itype,endpoint);
            String result = SalesforceLimitsDataSourceConnection.makeCallout(req);

            // check the result
            if ( result != null ) {
                List<HttpVersionResponse> parsedList = (List<HttpVersionResponse>)System.JSON.deserialize(result
                                                                                                          , List<HttpVersionResponse>.class);
                // able to parse
                if ( null != parsedList ) {
                    latestVersion = parsedList[parsedList.size()-1].version;

                }
            }
        } catch (Exception excp) {
            SalesforceLimitsDataSourceConnection.log(excp);
        }
        return latestVersion;
    }     // end of getLatestAPIVersion

    /**
     * createHttpRequest
     * @description create the http request from endpoint
     * @param  endpoint
     * @return HttpRequest
     */
    @TestVisible
    private static HttpRequest createHttpRequest(DataSource.IdentityType itype,string endpoint) {
        HttpRequest request = new HttpRequest();

        // if anonymous, set the session (sessionid can be null )
        if ( itype == DataSource.IdentityType.ANONYMOUS ) {
            String sessionId = SalesforceLimitsDataSourceConnection.getSessionId();
            if ( string.isNotBlank(sessionId)) {
                // Bearer
                request.setHeader('Authorization','Bearer '+ sessionId );
            }
        }
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        return request;
    }     // end of createHttpRequest
    /**
     * makeCallout
     * @description make the callout
     * @param  req the request
     * @return JSON data (String)
     */
    @TestVisible
    private static String makeCallout(HttpRequest req )
    {
        String result = null;
        try
        {
            final integer retryMax = 10;
            integer retryCount=0;
            Http callout = new Http();
            HttpResponse resp = callout.send(req);
            result = resp.getBody();

            // handle redirect
            while (resp.getStatusCode() == 302) {
                req.setEndpoint(resp.getHeader('Location'));
                resp = callout.send(req);
                retryCount++;
                // max retry then break out
                if ( retryCount == retryMax) {
                    break;
                }
            }
            // if not successful ??
            if(resp.getStatusCode() != 200) {
                SalesforceLimitsDataSourceConnection.log('[ERROR - salesforceApexLimitsCallout]:'+ result);
                result=null;
            }
        } catch (Exception excp) {
            SalesforceLimitsDataSourceConnection.log(excp);
        }

        return result;
    }     // end of makeCallout
    /**
     * getSessionId
     * @description get user session id
     * @return  session Id
     */
    @TestVisible
    private static String getSessionId(){
        String session =userinfo.getSessionId();
        // just for testing
        if ( SalesforceLimitsDataSourceConnection.isTesting ) {
            string visibleSessionId = EncodingUtil.base64Encode(Blob.valueOf(session));
            SalesforceLimitsDataSourceConnection.log('[DATA - getSessionId]:'+ visibleSessionId);
        }

        return session;
    }     // end of getSessionId

}    // end of SalesforceLimitsDataSourceConnection
