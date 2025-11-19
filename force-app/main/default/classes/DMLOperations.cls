/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Hanna Kuchminskaya
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account result = new Account(Name = 'Account' +string.ValueOf(Datetime.now().format()));

        insert result;
        // Return the Id of the newly created Account
        return result.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {

        // Create a new Account and set the fields inline
        Account acct = new Account(Name = name, Industry = industry);
        // Insert the Account
         insert acct;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance

        Contact result = new Contact();

        // Set some fields on the Contact
        result.LastName = 'Contact' + string.ValueOf(Datetime.now().format());

        // Set the AccountId field to the given accountId
        result.AccountId = accountId;

        // Insert the Contact into the database
        insert result;

        // Return the Id of the newly created Contact
        return result.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact result = [SELECT Id, LastName FROM Contact WHERE Id = :contactId];

        // Update the Contact's last name
        result.LastName = newLastName;

        // Update the Contact in the database
        update result;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity result = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId];
        
        // Update the Opportunity's stage
        result.StageName = newStage;

        // Update the Opportunity in the database
        update result;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]

        Account result = [SELECT id, Name, Industry from Account WHERE Id = :accountId];

        // Update the Account with the given Id with the new name and industry
        result.Name = newName;
        result.Industry = newIndustry;
        update result;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for (opportunity oppt:opportunities) {
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
            oppt.StageName = 'Qualification';
            oppt.CloseDate = date.today().addMonths(3);
            oppt.Amount = 50000;
            }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
        
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        Account accountToUpsert = new Account ();
        List<Account> existingAccounts= [SELECT Id, Name FROM Account WHERE Name =:accountName];
        if (existingAccounts.isEmpty()){
            Account newAccount = new Account(Name = accountName);
            accountToUpsert = newAccount;
        } else {
            accountToUpsert = existingAccounts[0];
        }
        upsert accountToUpsert;
        
        Set<String> opportunitiesNames = new Set<String>(oppNames);
        List<Opportunity> existingOpportunities = [SELECT Id, Name FROM Opportunity WHERE Name =:oppNames];
        for (Opportunity oppt :existingOpportunities){
            if (oppNames.contains(oppt.Name)){
                opportunitiesNames.remove(oppt.Name);
            }
        }
           // Loop through each Opportunity name
            // Create an Opportunity with the given name
            // Add the Opportunity to the list
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        for (string s: opportunitiesNames){
            Opportunity oppToAdd = new Opportunity (Name = s);
            opportunitiesToInsert.add(oppToAdd);
        }
        opportunitiesToInsert.addAll(existingOpportunities);
        for (Opportunity oppt :opportunitiesToInsert){
            oppt.AccountId = accountToUpsert.Id;
            oppt.StageName = 'Qualification';
            oppt.CloseDate = date.today().addMonths(3);
            
        }
        upsert opportunitiesToInsert;

     
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
	    List<Account> accounts = [SELECT Id, Name, Description FROM Account WHERE Name = :accountName LIMIT 1];
        Account account;

            if (!accounts.isEmpty()) {
                account= accounts[0];
                account.Description = 'Updated Account';
            } else {
                // otherwise, create a new Account and set the description
	
                account = new Account (Name = accountName, 
                Description = 'New Account');     
            }
            

		// Upsert the Account
            upsert account;
           
        		
		return account;
	}

 
    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        // Extract the Account Name from Contact's LastName
        Set<String> lastNames = new Set<String>();
                           
        For (contact c: contactsToUpsert) {
            if (c.LastName != null) {           
            lastNames.add(c.LastName);
            }
        }
       
          // Get the account based on the name or create one if it doesn't exist
        Map <String, Account> existingAccounts = new Map<String, Account> ();
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :lastNames]) {
        existingAccounts.put(acc.Name.toLowerCase(), acc);
    }
        List<Account> accountsToInsert = new List<Account>();
        for (string s : lastNames) {
            if (!existingAccounts.containsKey(s.toLowerCase())){
                accountsToInsert.add(new Account (Name = s));
            }
        }
        insert accountsToInsert;
        for (Account acc : accountsToInsert) {
            existingAccounts.put(acc.Name.toLowerCase(), acc);
        }

        for (Contact c : contactsToUpsert){
            Account relatedAccount = existingAccounts.get(c.LastName.toLowerCase());
            if (relatedAccount != null)
            {
                c.AccountId = relatedAccount.Id;
            }
            
        }
         upsert contactsToUpsert;
	 
	}


    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        List<Lead> leadsToInsert = new List<Lead>();
        for (string s: leadNames){
            Lead leadToInsert = new Lead (LastName = s, Company = s);
            leadsToInsert.add(leadToInsert);
        }

        // Insert the Leads
        insert leadsToInsert;

        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToInsert = new List<Case>();
        for (integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case(AccountId = accountId);
            casesToInsert.add(newCase);
        }
        // Insert the cases
        insert casesToInsert;

        // Delete the cases
        delete casesToInsert;
    }
}