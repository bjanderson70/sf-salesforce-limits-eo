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

}