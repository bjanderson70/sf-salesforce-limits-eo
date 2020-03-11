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
 *
 * @File Name: SalesforceLimitsDataSourceProvider.cls
 * @Description        : Salesforce Limits Provider
 * @Author             : Bill Anderson
 * @Group              : Provider
 *
 **/
global with sharing class SalesforceLimitsDataSourceProvider extends DataSource.Provider {

    /**
     * getAuthenticationCapabilities
     * @description what capabilities we support
     * @return collection of capabilities
     */
    override global List<DataSource.AuthenticationCapability> getAuthenticationCapabilities()
    {
        List<DataSource.AuthenticationCapability> capabilities =
            new List<DataSource.AuthenticationCapability> {
            // applies to Classic -- 
            // Lightning, the session is NOT API enable ( have to use Named Credentials)
            DataSource.AuthenticationCapability.ANONYMOUS,
            DataSource.AuthenticationCapability.OAUTH
        };
        return capabilities;
    }// end of getAuthenticationCapabilities
    /**
     * getCapabilities 
     * @description get Capabilities
     * @return   collection of Capabilities
     */
    override global List<DataSource.Capability> getCapabilities()
    {
        List<DataSource.Capability> capabilities = new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
    
        return capabilities;
    }// end of getCapabilities
    /**
     * getConnection description
     * @param  connectionParams connectionParams description
     * @return                  return description
     */
    override global DataSource.Connection getConnection(DataSource.ConnectionParams connectionParams)
    {
        return new SalesforceLimitsDataSourceConnection(connectionParams);
    }// end of getConnection

} // end of SalesforceLimitsDataSourceProvider
