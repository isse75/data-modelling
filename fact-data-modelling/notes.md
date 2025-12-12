# Fact Data Modelling

**Facts** represent something that has happened e.g. transaction, event
- They often are 10-100x volume of dimensional tables due to detailed records
- Facts are immutable once recorded (historical data)
- Facts often appear in layers -> used for aggregations in calculations (e.g. total steps, avg steps per day)


**Normalisation** - No dimensional attributes in fact table, only IDs to retrieve the information
- This can be slower

**Denormalisation** - Brings in attributes into fact table rather than using dimension tables
- Can cause duplicates


### Key Aspects to consider when Fact Data Modelling
- **Who**: Entities/Individuals associated with data
- **What**: Action/Event/Object data pertains to
- **Where**: Location of event/transaction or data origin
- **When**: Time event occured
- **How**: Process behind data creation/transformation

## Common Techniques
- **Sampling**: Works well on metric-driven use-cases, not where governance is critical
- **Broadcast Join**: Only works when one side of join is small
- **Bucketing**: Avoids need for expensive reshuffling by pre-partitioning tables
