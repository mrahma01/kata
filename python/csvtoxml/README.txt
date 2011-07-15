Campbell-Lange Workshop Ltd (CLW)

This is an exercise given to candidates applying for programming
positions at CLW. 

The aim of this exercise is to show us your approach to writing Python
programmes. Your approach is more important than completeness. No more
than 4 hours should be spent on the exercise.

The file 'company_list.csv' contains a list of randomised companies and
their office locations. The task is to create an xml document of the
data supporting the following hierachy, which should be semantically the
same as the company_hierarchy.xml document.

The data structure of the XML document is as follows:

	Company
	|
	\- Office
	   |
	   \- Department

- Where Company is the name of the trading company, such as "Hamptons",
  sorted alphabetically.
- The Office is the location in which is Office is situated, such as
  "Mayfair", sorted alphabetically.
- The Department would be "Sales", "Lettings", "Short Lettings",
  "Country Homes", etc, sorted alphabetically.


Rules.

 * Must use Python 2.6.x or 2.7.x
 * Do not use Python 3.x.x
 * You cannot modify the company_list.csv file in any way
 * You may create additional python modules
 * You may use additional third party libraries

 * Each Company must have at least one Office
 * Each Company must have a name
 * The Company name must not contain the Office name
 * The Company Name must not contain the Department

 * Each Office must have at least one Department
 * The Office name is extracted from the name column,
   If not present in the name column it will be taken from the office column
   If not present in the office column it will be taken from the address column
   If not present in the address column it will be 'Head Office'
 * The Office name must not contain the Company name or Department
 * Remove the word 'closed' from any Office Names

 * The Department name will be extracted from the name column
   If not found in the name column it will default to 'Sales'
   Unless there is a 'Sales' department represented by another row in the CSV
   In this case it will be a 'Lettings' department
   Unless there is a 'Lettings' department represented by another row in the CSV
   In this case it will be an 'Unknown' department
 * Department names within the same Office must be unique
   Duplicate Departments with same name can be discarded
 * The Department name must not contain the Company or Office name
 * The Department will contain the original ID from the CSV

 * Your coding style and approach to solving the problem is more important than
   successfully completing the exercise.
