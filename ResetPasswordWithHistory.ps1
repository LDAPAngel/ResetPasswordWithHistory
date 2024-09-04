
$code=@"
using System;
using System.DirectoryServices.Protocols;
using System.Text;
namespace Password
{
    public class Reset
    {
        public static void PreserveHistory()
        {
            LdapConnection ldapConnection = new LdapConnection("192.168.4.211");
            ldapConnection.Credential = new System.Net.NetworkCredential("administrator", "P@ssword");
            ldapConnection.SessionOptions.Signing = true;
            ldapConnection.SessionOptions.Sealing = true;
            ldapConnection.AuthType = AuthType.Negotiate;
            ldapConnection.SessionOptions.ProtocolVersion = 3;

            string password ='"'+ "newP@ssword" +'"';
            string userDN = "CN=User01,OU=Test,DC=acme,DC=local";
			
			
            DirectoryAttributeModification passwordMod = new DirectoryAttributeModification();
            passwordMod.Name = "unicodePwd";
            passwordMod.Add(Encoding.Unicode.GetBytes(password));

            passwordMod.Operation = DirectoryAttributeOperation.Replace;

            ModifyRequest request = new ModifyRequest(userDN, passwordMod);



            byte[] ctrlData = BerConverter.Encode("{i}", new Object[] { 1 });
            DirectoryControl LDAP_SERVER_POLICY_HINTS_OID = new DirectoryControl("1.2.840.113556.1.4.2239", ctrlData, true, true);

            request.Controls.Add(LDAP_SERVER_POLICY_HINTS_OID);

                                  
            try
            {
                DirectoryResponse response = ldapConnection.SendRequest(request);
                Console.WriteLine(response.ResultCode);
                Console.ReadKey();

            }
            catch(Exception err)
            {
                // if the reset fails will get an error of The server cannot handle directory requests
                Console.WriteLine(err.Message);
                Console.ReadKey();
            }
        }
    }
}
"@

$assemblies = ("System.Core","System.Xml.Linq","System.Data","System.Xml", "System.Data.DataSetExtensions", "Microsoft.CSharp","System.DirectoryServices.Protocols")
Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $code -Language CSharp	
[Password.Reset]::PreserveHistory()