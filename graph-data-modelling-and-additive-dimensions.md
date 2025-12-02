**Graph Database Modelling**

**Additive Dimensions:** Means you don’t double count (Add all of the sizes of each group)  
E.g. population is equal to no of 20 year olds \+ 30 year olds \+ 40 year olds …  
Number of honda drivers is not equal to no of civic drivers, corolla drivers etc.. because an individual can own 2 meaning they will be double counted.

Dimension is additive in window of time, if grain of data over that window can be 1 value at a time.

- Additivity helps as you don’t need to use COUNT(DISTINCT) on preaggregared dimensions

**Enumerations \-** Good for low-to-medium cardinality

- Built in data quality  
- Built in static fields  
- Built in documentation

Enumerations chunk up big data problem into manageable pieces

Group Enumerations into a “little book of Enums”.

Enums pushed into source functions \-\> source functions map into a shared schema \-\> DQ Checks \-\> Subpartitioned Output

How is the little book of enums generated: Enumeration defined by python or scala, job defines this into a table based on number of enums, share it with source functions by passing it as python, share with the dq checks by passing it as table, and then join.

- Useful in large scale data integrations  
- Useful when needing tons of sources mapping to shared schema

**Modelling Data from Disparate Sources into Shared Schema?**  
Flexible Schema  
Leverage alot of map data types

Benefits:

- You dont have to run ALTER TABLE commands  
- You can manage more columns  
- Not many NULL columns in schema  
- “Other\_properties” column is pretty awesome for rarely-used-but-needed columns

Drawbacks:

- Compression is worse (especially if you use JSON)  
- Readability  
- Queryability

**Graph Data Modeling is RELATIONSHIP focused not ENTITY focused.**  
All Vertex Data Models have virtually the same schema  
Usually the model looks like:

* Identifier: STRING  
* Type: STRING  
* Properties: MAP\<STRING, STRING\>

Edge Data Models are modeled a little bit more in depth

* subject\_identifier: STRING  
* subject\_type: VERTEX\_TYPE  
* object\_identifier: STRING  
* object\_type: VERTEX\_TYPE  
* edge\_type: EDGE\_TYPE  
* Properties: MAP\<STRING, STRING\>

E.g. subject\_id \= player\_name, subject\_type \= player, object\_id \= team\_name, object\_type \= team, edge\_type \= plays on 