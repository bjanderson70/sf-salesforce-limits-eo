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
 * @File Name          : SalesforceLimitsDataSourceConnectionTest.cls
 * @Description        : Test External Object for Salesforce Limits Connection
 *
 * @Author             : Bill Anderson
 * @Group              : External Data Source
 **/

@isTest
private class SalesforceLimitsDataSourceConnectionTest {

    ///////////////////////////////////////////////////////////////
    // Data members
    ///////////////////////////////////////////////////////////////

    static List<String> fieldNames = new List<String> {
        SalesforceLimitsDataSourceConnection.FIELDNAME_MAX
        ,SalesforceLimitsDataSourceConnection.FIELDNAME_NAME
        ,SalesforceLimitsDataSourceConnection.FIELDNAME_RATIO
        ,SalesforceLimitsDataSourceConnection.FIELDNAME_REMAINING
        ,SalesforceLimitsDataSourceConnection.FIELDNAME_EXTERNAL_ID
        ,SalesforceLimitsDataSourceConnection.FIELDNAME_DISPLAY_URL
    };
    static Map<String,SalesforceLimitsDataSourceConnection.LimitResults> testOracle= new  Map<String,SalesforceLimitsDataSourceConnection.LimitResults> {
        'test'=> new SalesforceLimitsDataSourceConnection.LimitResults('test',10,5)
        ,'test2'=> new SalesforceLimitsDataSourceConnection.LimitResults('test2',100,100)
        ,'test1'=> new SalesforceLimitsDataSourceConnection.LimitResults('test1',1000,1)
    };
    static List<SalesforceLimitsDataSourceConnection.LimitResults> testCompare= new  List<SalesforceLimitsDataSourceConnection.LimitResults> {
        new SalesforceLimitsDataSourceConnection.LimitResults('test',1000,500)
        ,new SalesforceLimitsDataSourceConnection.LimitResults('test2',100000,10)
        ,new SalesforceLimitsDataSourceConnection.LimitResults('test1',100,100)
    };
    static Set<String> contentSet = new Set<String> {
        'test'
        ,'test1'
        ,'test2'
    };
    static List<String> sortByNameList = new List<String> {
        'test'
        ,'test1'
        ,'test2'
    };
    static List<String> sortByMaxList = new List<String> {
        'test1'
        ,'test'
        ,'test2'
    };
    static List<String> sortByRemainList = new List<String> {
        'test2'
        ,'test1'
        ,'test'
    };
    @TestVisible
    static final String FILTER = 'DailyApiRequests';
    @TestVisible
    static final String MOCK_LIMIT_FIELD = 'AnalyticsExternalDataSizeMB';

    @TestVisible
    class TestException extends Exception {}

    /*
     * This mock will be used when we call out (API) for salesforce limit
     */
    public class MockLimitsHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"' + MOCK_LIMIT_FIELD + '":{"Max":1000,"Remaining":100}}');
            res.setStatusCode(200);
            return res;
        }
    }// end of MockLimitsHttpResponseGenerator
     /*
      * This mock will be used when we call out (API) for version
      */
    public class MockAPIVersionHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('GET', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody ('[{"label":"Spring 20","url":"/services/data/v48.0", "version":"48.0"}]');
            res.setStatusCode(200);
            return res;
        }
    } // end of MockLimitsHttpResponseGenerator

    ///////////////////////////////////////////////////////////////
    // Unit Tests
    ///////////////////////////////////////////////////////////////
    /*
     * Test query
     */
    @isTest
    static void testquery(){
        DataSource.QueryContext query = SalesforceLimitsDataSourceConnectionTest.createQuery();
        // assign
        SalesforceLimitsDataSourceConnection ctor = new SalesforceLimitsDataSourceConnection();
        // act
        ctor.query(query);

    } // end of testquery
    /*
     * Test getSessionId
     */
    @isTest
    static void testgetSessionId(){
        // assign
        final string sessionInfo = '[DATA - getSessionId]';
        // act
        String value=SalesforceLimitsDataSourceConnection.getSessionId();
        // assert
        system.assertEquals(true, SalesforceLimitsDataSourceConnectionTest.containedInLog(sessionInfo));
        system.assertEquals(true, string.isNotEmpty(value));
    }// end of testgetSessionId

    /*
     * Test getLatestAPIVersion
     */
    @isTest
    static void testgetLatestAPIVersion() {
        // assign
        Test.setMock(HttpCalloutMock.class, new MockAPIVersionHttpResponseGenerator());
        DataSource.IdentityType itype = DataSource.IdentityType.ANONYMOUS;
        // act
        String version=SalesforceLimitsDataSourceConnection.getLatestAPIVersion(itype);
        // assert
        system.assertEquals(SalesforceLimitsDataSourceConnection.SERVICE_VERSION, version);

    }// end of testgetLatestAPIVersion
    /*
     * Test getFilterSoqlTerm
     */
    @isTest
    static void testgetFilterSoqlTerm() {
        // assign
        SalesforceLimitsDataSourceConnection ctor = new SalesforceLimitsDataSourceConnection();
        Test.startTest();
        // act
        ctor.getFilterSoqlTerm(null);
        Test.stopTest();
        // assert
        system.assertEquals('', ctor.limitWhere);
        system.assertEquals ('',ctor.limitWhereValue);
        system.assertEquals (DataSource.FilterType.EQUALS,ctor.limitFilterType);


    }// end of testgetFilterSoqlTerm

    /*
     * Test getOrderSoqlTerm
     */
    @isTest
    static void testgetOrderSoqlTerm() {
        // assign
        SalesforceLimitsDataSourceConnection ctor = new SalesforceLimitsDataSourceConnection();
        // act
        ctor.getOrderSoqlTerm(null);
        // assert
        system.assertEquals(SalesforceLimitsDataSourceConnection.FIELDNAME_NAME, ctor.limitOrderBy);
        system.assertEquals (true,ctor.limitAscending);

        // assign
        List<DataSource.Order> orders = SalesforceLimitsDataSourceConnectionTest.createOrders(SalesforceLimitsDataSourceConnection.FIELDNAME_MAX);

        // act
        ctor.getOrderSoqlTerm(orders);
        // assert
        system.assertEquals(SalesforceLimitsDataSourceConnection.FIELDNAME_MAX, ctor.limitOrderBy);
        system.assertEquals (false,ctor.limitAscending);


    }// end of testgetOrderSoqlTerm
    /*
     * Test salesforceApexLimitsCallout
     */
    @isTest
    static void testsalesforceApexLimitsCallout(){

        // assign
        SalesforceLimitsDataSourceConnection ctor = new SalesforceLimitsDataSourceConnection();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockLimitsHttpResponseGenerator());

        List<SalesforceLimitsDataSourceConnection.LimitResultsWrapper> wrapper=ctor.salesforceApexLimitsCallout();

        // there should only be one
        SalesforceLimitsDataSourceConnection.LimitResultsWrapper wrap = wrapper[0];

        System.assertEquals(1, wrapper.size());
        // see MockLimitsHttpResponseGenerator above
        System.assertEquals(MOCK_LIMIT_FIELD, wrap.lresult.name);
        System.assertEquals(1000, wrap.lresult.max);
        System.assertEquals(100, wrap.lresult.remaining);

    }// end of testsalesforceApexLimitsCallout
    /*
     * Test sync
     */
    @isTest
    static void testsync() {
        // assign
        SalesforceLimitsDataSourceConnection ctor = new SalesforceLimitsDataSourceConnection();
        // act
        List<DataSource.Table> tables=ctor.sync();

        for ( Datasource.Table table : tables) {
            // check the fields
            for ( Datasource.Column column : table.columns ) {
                String cname = column.name;
                Boolean found = false;
                for ( String lname : fieldNames) {
                    if ( lname==cname ) {
                        found=true;
                        break;
                    }
                }
                system.assertEquals(true, found);
            }
            system.assertEquals ( SalesforceLimitsDataSourceConnection.DESCRIPTION,table.description);
            system.assertEquals ( SalesforceLimitsDataSourceConnection.DESCRIPTION,table.labelPlural);
            system.assertEquals ( SalesforceLimitsDataSourceConnection.LABEL_SINGULAR,table.labelSingular);
        }
        system.assertEquals ( 1,tables.size());

    }// end of testsync

    /*
     * Test compareValues
     */
    @isTest
    static void testlog() {
        Map<String,String> messages = new Map<String,String> {
            '1'=> 'message 1'
            ,'2' => null
            ,'3' => 'message 3'
        };

        for (String key: messages.keySet()) {
            String msg = messages.get(key);
            Boolean expected = msg == null ? false : true;

            SalesforceLimitsDataSourceConnection.log(msg);
            SalesforceLimitsDataSourceConnection.log(new TestException(msg));
            // assert
            system.assertEquals(expected, SalesforceLimitsDataSourceConnectionTest.containedInLog(msg));
        }
    }// end of testlog

    /*
     * Test compareValues
     */
    @isTest
    static void testtheLimits() {
        List<SalesforceLimitsDataSourceConnection.LimitResultsWrapper> wrapper= new  List<SalesforceLimitsDataSourceConnection.LimitResultsWrapper>();
        SalesforceLimitsDataSourceConnection ctor= new SalesforceLimitsDataSourceConnection();
        for (SalesforceLimitsDataSourceConnection.LimitResults lr: testOracle.values() ) {
            wrapper.add(new SalesforceLimitsDataSourceConnection.LimitResultsWrapper(lr));

        }
        ctor.theLimits = wrapper;
        system.assertEquals (wrapper.size(),ctor.theLimits.size());
        for ( SalesforceLimitsDataSourceConnection.LimitResultsWrapper wrap: wrapper) {
            if ( !contentSet.contains(wrap.name)) {
                system.assertEquals(false, true,'testtheLimits:The Limits property did not contain a limit result name');
            }
        }

    }// end of testtheLimits
    /*
     * Test compareValues
     */
    @isTest
    static void testctors() {
        DataSource.ConnectionParams cparams = new DataSource.ConnectionParams();
        cparams.principalType = DataSource.IdentityType.NAMED_USER;

        List<SalesforceLimitsDataSourceConnection> ctors = new List<SalesforceLimitsDataSourceConnection> {
            new SalesforceLimitsDataSourceConnection(null),
            new SalesforceLimitsDataSourceConnection ()

        };
        for (SalesforceLimitsDataSourceConnection ctor: ctors ) {
            system.assertEquals(true, ctor != null);
            system.assertEquals (null,ctor.theLimits);
            system.assertEquals ('', ctor.limitWhere);
            system.assertEquals ('',ctor.limitWhereValue);
            system.assertEquals (true,ctor.limitAscending);
            system.assertEquals (SalesforceLimitsDataSourceConnection.FIELDNAME_NAME, ctor.limitOrderBy);
            system.assertEquals (0, ctor.limitOffset);
            system.assertEquals ( DataSource.IdentityType.ANONYMOUS,ctor.limitIdentityType);
        }
        SalesforceLimitsDataSourceConnection ctor= new SalesforceLimitsDataSourceConnection (cparams);
        system.assertEquals(true, ctor != null);
        system.assertEquals (null,ctor.theLimits);
        system.assertEquals ('', ctor.limitWhere);
        system.assertEquals ('',ctor.limitWhereValue);
        system.assertEquals (true,ctor.limitAscending);
        system.assertEquals (SalesforceLimitsDataSourceConnection.FIELDNAME_NAME, ctor.limitOrderBy);
        system.assertEquals (0, ctor.limitOffset);
        system.assertEquals ( DataSource.IdentityType.NAMED_USER,ctor.limitIdentityType);
    }// end of testctors
    /*
     * Test compareValues
     */
    @isTest
    static void testcompareValues() {
        Map<String,Integer> comparison = new Map<String,Integer> {
            SalesforceLimitsDataSourceConnection.FIELDNAME_MAX => -1
            ,SalesforceLimitsDataSourceConnection.FIELDNAME_NAME => -1
            ,SalesforceLimitsDataSourceConnection.FIELDNAME_RATIO => -1
            ,SalesforceLimitsDataSourceConnection.FIELDNAME_REMAINING => 0
            ,SalesforceLimitsDataSourceConnection.FIELDNAME_EXTERNAL_ID => 1
            ,SalesforceLimitsDataSourceConnection.FIELDNAME_DISPLAY_URL => -1
        };
        SalesforceLimitsDataSourceConnection.LimitResults lr1=new SalesforceLimitsDataSourceConnection.LimitResults('compare1',1000,500);
        SalesforceLimitsDataSourceConnection.LimitResults lr2=new SalesforceLimitsDataSourceConnection.LimitResults('compare2',2000,500);
        SalesforceLimitsDataSourceConnection.LimitResultsWrapper wrapper1=new SalesforceLimitsDataSourceConnection.LimitResultsWrapper(lr1);
        SalesforceLimitsDataSourceConnection.LimitResultsWrapper wrapper2=new SalesforceLimitsDataSourceConnection.LimitResultsWrapper(lr2);

        for ( string name : fieldNames) {
            system.assertEquals(comparison.get(name), wrapper1.compareValues(name
                                                                             ,wrapper1.getBy(name)
                                                                             ,wrapper2.getBy(name) ));
        }

    }// end of testcompareValues
    /*
     * Test sort and compareTo
     */
    @isTest
    static void testLimitResultsWrapper_compareTo() {

        /*
         * comparing equality
         */
        for (SalesforceLimitsDataSourceConnection.LimitResults compareTo: testCompare ) {
            SalesforceLimitsDataSourceConnection.LimitResultsWrapper wrapper=new SalesforceLimitsDataSourceConnection.LimitResultsWrapper(compareTo);
            integer equality = wrapper.compareTo (new SalesforceLimitsDataSourceConnection.LimitResultsWrapper(testOracle.get(compareTo.name))),
                    badData = wrapper.compareTo (null);

            system.assertEquals(true, equality==0);
            system.assertEquals(-1, badData);
        }


        /*************************************************************************
        * checking sorts
        *************************************************************************/
        List<SalesforceLimitsDataSourceConnection.LimitResultsWrapper> wrapperList = new List<SalesforceLimitsDataSourceConnection.LimitResultsWrapper>();
        // set the wrapper list
        for (SalesforceLimitsDataSourceConnection.LimitResults item: testCompare ) {
            wrapperList.add(new SalesforceLimitsDataSourceConnection.LimitResultsWrapper(item));
        }
        //+++++++++++++++++++
        // sorting by name
        //+++++++++++++++++++
        wrapperList.sort();
        Integer inx=0;
        // ensure order is correct for name
        for (SalesforceLimitsDataSourceConnection.LimitResultsWrapper cwrap: wrapperList) {
            system.assertEquals (true,sortByNameList[inx] == cwrap.name);
            // getting ready for next compare
            cwrap.sortBy = SalesforceLimitsDataSourceConnection.FIELDNAME_MAX;
            inx++;
        }
        //+++++++++++++++++++
        // sorting by Max
        //+++++++++++++++++++
        wrapperList.sort();
        inx=0;
        // ensure order is correct
        for (SalesforceLimitsDataSourceConnection.LimitResultsWrapper cwrap: wrapperList) {
            system.assertEquals (true,sortByMaxList[inx] == cwrap.name);
            // getting ready for next compare
            cwrap.sortBy = SalesforceLimitsDataSourceConnection.FIELDNAME_REMAINING;
            inx++;
        }
        //+++++++++++++++++++
        // sorting by Remaining
        //+++++++++++++++++++
        wrapperList.sort();
        inx=0;
        // ensure order is correct
        for (SalesforceLimitsDataSourceConnection.LimitResultsWrapper cwrap: wrapperList) {
            system.assertEquals (true,sortByRemainList[inx] == cwrap.name);
            inx++;
        }

    }// end of testLimitResultsWrapper_compareTo

    ///////////////////////////////////////////////////////////////////////////////
    // Helpers
    ///////////////////////////////////////////////////////////////////////////////

    static boolean containedInLog(string message) {
        // is message in static container
        if ( message != null) {
            // iterate as this is not a set
            for ( String value : SalesforceLimitsDataSourceConnection.testLogMessages) {
                if ( value.contains(message)) { return true;}
            }
        }
        return false;
    }//end of containedInLog

    static List<DataSource.Order> createOrders() {
        return SalesforceLimitsDataSourceConnectionTest.createOrders(SalesforceLimitsDataSourceConnection.FIELDNAME_NAME);
    } // end of createOrders

    static List<DataSource.Order> createOrders(string fieldname) {
        String fname = string.isEmpty(fieldname) ? SalesforceLimitsDataSourceConnection.FIELDNAME_NAME : fieldname;

        List<DataSource.Order> orders = new List<DataSource.Order>();
        DataSource.Order order = new DataSource.Order();
        order.columnName=fname;
        order.direction=Datasource.OrderDirection.DESCENDING;
        order.tableName=SalesforceLimitsDataSourceConnection.TABLE_NAME;

        orders.add(order);

        return orders;
    }// end of createOrders

    static DataSource.Filter createFilter() {
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = SalesforceLimitsDataSourceConnection.FIELDNAME_NAME;
        filter.columnValue = FILTER;
        filter.subfilters = null;
        filter.tableName = SalesforceLimitsDataSourceConnection.TABLE_NAME;
        filter.type=DataSource.FilterType.EQUALS;
        return filter;
    }// end of createFilter

    static DataSource.QueryContext createQuery() {

        DataSource.QueryContext query = new DataSource.QueryContext();
        List<DataSource.ColumnSelection> cselection = new  List<DataSource.ColumnSelection>();
        DataSource.ColumnSelection sel1= new DataSource.ColumnSelection();
        DataSource.ColumnSelection sel2=new DataSource.ColumnSelection();

        query.tableSelection = new DataSource.TableSelection();

        sel1.columnName=SalesforceLimitsDataSourceConnection.FIELDNAME_MAX;
        sel1.tableName=SalesforceLimitsDataSourceConnection.TABLE_NAME;
        sel1.aggregation=DataSource.QueryAggregation.NONE;

        sel2.columnName=SalesforceLimitsDataSourceConnection.FIELDNAME_NAME;
        sel2.tableName=SalesforceLimitsDataSourceConnection.TABLE_NAME;
        sel2.aggregation=DataSource.QueryAggregation.NONE;

        cselection.add(sel1);
        cselection.add(sel2);

        query.maxResults=1;
        query.offset=0;
        query.tableSelection.filter=SalesforceLimitsDataSourceConnectionTest.createFilter();
        query.tableSelection.order = SalesforceLimitsDataSourceConnectionTest.createOrders();
        query.tableSelection.columnsSelected=cselection;

        return query;
    }// end of createQuery

}// end of SalesforceLimitsDataSourceConnectionTest