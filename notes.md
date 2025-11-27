**Data Modelling – Kimball**
  
Goal is to categorise data into their fact or dimensional models.

 **Fact (“verb”) –** Collection of info that refers to action/event/result of a business process.
- Fact tables act as historical record of actions. You should almost never overwrite data when updating is required. Instead, add new data as additional rows
- Fact tables capture all the touchpoints leading to action, helping understand what lead to action
**Dimension (“noun”) -** Collection of data that describe who or what took action / affected by action.
Add context to stored events in fact tables, e.g. users, accounts, customers, invoices
You should not add/diplicate to dimension tables, you should overwrite as nouns do not change.

**Star Schema** - One central fact table that can join to relevant dimension tables
**Snowflake Schema** - Extension of star schema where dimension tables link to other dimension tables

**Keys**:
- **Primary Key:** Column in table that uniquely identifies each row
- **Foreign Key:** Column in table that refers to primary key of other table
- **Surrogate key:** Artificial column uniquely identifies each row, created when no natural primary key exists. (Sys generated or via Hashing)


**4 step design process:**
- Selecting Business Process to Analyse
- Declaring Grain*
- Identifying Dimensions
- Identifying Facts

***Grain = Combination of columns at which records in table are unique***


**Deciding Fact vs Dimension**

Case by case basis, an entity can be viewed as a fact or dimension depending on analysis you are trying to run
E.g. You run a clinic, you have a log of appointments by patient.
Naturally, appointments are facts and patients are dimensions as patients can have multiple dimensions.
BUT what if the business team wants to analyse appointment data, e.g. how appointment went, when it happened, duration etc.
THEN in this scenario, you can make case for appointments as dimension table and patients as facts.

**Wide Tables vs Separate?**

Smaller individual tables was cheaper back in the day. No keeping tables separate can be expensive as every time you join, you’re spending computing credits. 

DEPENDS.

If end business users comfortable with sql and joins then keeping data separate as fact and dimension tables is great. Freedom and Flexibility to join and explore.

If they are not, then should consider joining them into wide tables.


**Advantages and Disadvantages of Dimensional Modelling**

***Advantages:***

- **More Accessibility:** Tables easier to understand and more accessible to end consumers
- **More Flexibility:** Easy to slice, dice, filter and view data in way that suits purpose
- **Faster Performance:** Fact and Dimension Models materialised as tables. These are queried often, allows better performance in downstream BI platforms.

***Disadvantages:***

- **Navigating ambiguity:** You need to rely on your understanding of your data and stakeholder wants to model your data in a comprehensible and useful way
- **Utility Limited by BI Tool:** Some BI tools don’t handle joins well, which can make queries from separated fact and dimensional tables painful
