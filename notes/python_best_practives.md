# From quantified-code/python-anti-patterns on GitHub

- Use named tuples when returning more than one value from a function
- Raise an error instead of returning None which is causing multiple return types
- Think EAFP, Easier to Ask for Forgiveness than Permission: assume file exists, catch OSError if not, don't verify
- Use defaultdict instead of using condition to set item to a base value if it does not exist
- Use explicit unpacking, don't access tuple elements by index
