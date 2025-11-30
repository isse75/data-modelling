**Dimensional Data Modelling**

**Dimensions:** Attributes of an entity \- e.g. birthday, favourite food

**2 Types of Attributes:**

- Slowly-changing Attributes (e.g. favourite food)  
- Fixed (e.g. Birthday, Manufacturer of phone)

**First Understand, Consumer.**

- Data Analysts/Scientists. Flat data, easy to query  
- Data Engineers, compact, nested types should be ok  
- Customers, easy to interpret chart 

**OLTP (Online Transaction Processing)**

- Used by software engineers  
- Looks at one entity  
- Optimised for low latency, low volume queries

**OLAP (Online Analytical Processing)**

- Used by data engineers  
- Optimised for large volumes, group by queries, minimised joined

**Master Data** 

- Looks at one entity  
- Prevents forcing OLTP layer into OLAP (vice-versa)  
- Hybrid of OLAP & OLTP. Optimised for completeness of entity definitions, deduplicated  
- ARRAY, MAP, STRUCT Datatypes

**Cumulative Table Design**

- 2 Dataframes, Yesterday and Today  
- FULL OUTER JOIN of 2 Dataframes together  
- COALESCE values to keep all values  
- Hang onto all history  
- **Use Case: e.g.** Growth Analytics (dim\_all\_users)

     *Advantages*

- Historical Analysis w/o shuffling  
- Easy “transition” analysis

     *Disadvantages*

- Must be backfilled sequentially  
- Handling PII data can be difficult, as deleted/inactive users get carried forward

**Compactness vs Usability Tradeoff**

- Most usable tables usually   
  - Have no complex data types  
  - Easily Manipulated

- Most compact tables are compressed to be as small as possible, NOT QUERIFIABLE

- Middle ground tables use complex data types (e.g. ARRAY, MAP, STRUCT), makes queries more difficult but compacts 

**Complex Data Types**

- Struct: Keys are rigidly defined, compression is good. Values can be any type   
    
- Map: Keys are loosely defined, compression is okay. Values all have to be the same type   
    
- Array: Ordinal \- List of values that all have to be the same type

**Cardinality Explosions of Dimensions**

When you add a time dimension to your data, the size of the dataset can increase by a large factor (at least 10 times). For example, Airbnb has around 6 million listings. If you want to track the price and availability for each night over the next year, you’ll need data for 365 days per listing. This means you'd have to store data for about 2 billion nights (6 million listings \* 365 nights).

You have two options for how to structure this data:

- Listing-level with an array of nights: Store one row per listing, with an array holding the price and availability for each of the 365 nights. This way, you’ll have 6 million rows, each containing an array of 365 values.

- Listing-night level with 2 billion rows: Store one row for every night of every listing. This results in 2 billion rows, with each row representing the price and availability for one listing on one night.

- The storage size of these two options can end up being similar. This is because Parquet, a file format for storing data, can compress the data efficiently. As long as the data is sorted correctly, Parquet will likely compress both structures to similar sizes.

Disadvantages: 

- Exploding/Flattening data can lead to inefficient joins and poor compression when working with large datasets in Spark.

**SLOWLY CHANGING DIMENSIONS AND IDEMPOTENCY**

**Idempotent Pipelines:** Pipelines that produce the same results, regardless of when it is ran

Pipelines should produce same results, regardless of day ran, how many times run, hour they’re run.

**Causes of Non-Idempotency:**

- Using INSERT INTO without TRUNCATE:  
  - Using MERGE or INSERT OVERWRITE is the better option  
- Using start\_date \> without corresponding end\_date \<  
- Not using full set of partition sensors  
- Not using sequential processing in sequential pipeline (**e.g. depends\_on\_past)**  
- Relying on latest partition of a not properly modeled SCD table

**Issues with Non-Idempotency:**

- Backfilling causes inconsistencies with data  
- Hard to troubleshoot bugs  
- Silent failures \- only alerted to failures by end users  
- Unit testing can’t replicate production behaviour

**SLOWLY CHANGING DIMENSION**

SCD \- Dimension that slowly changes over time

**Modellling Dimensions that change \- SCD Types 01,2,3** 

Type 0 \- Not slowly changing. (e.g. DOB, Gender)

Type 1 \- Only care about latest value. (NEVER USE THIS TYPE, MAKES PIPELINES IDEMPOTENT)

Type 2 \- “Gold Standard”:

- Care about what value was from “start\_date” to “end\_date”. Current values have either a NULL end\_date or end\_date far in the future (e.g. 9999-12-31)  
- Hard to use, since more than 1 row per dimension  
- ONLY SCD that is IDEMPOTENT

Type 3 \- Only care about Orignal value and Current Value. Only 1 row per dimension, but lose history between current and original. Partially Idempotent

**Loading SCD2 (Type 2\)**

- Load entire history via one query  
  - Inefficient but nimble  
  - 1 query and done

- Incrementally load the data after previous SCD is generated  
  - Has same **depends\_on\_past** constraint  
  - Efficient but cumbersome

