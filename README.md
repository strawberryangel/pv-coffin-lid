# Custom Coffin Door Script

This is a modified version of a configurable door script 
that is controlled by link messages. This is now a stand-alone script.

The link messages have been removed, 
and the door operates by touch. 

The configuration values are hard-coded. 

## Updating the Coffin 

This requires knowledge of how to edit linked objects in SecondLife. 

1.  Remove all scripts from the *coffin lid*. 

1.  Put this updated script into the *coffin lid*. 
    If this is put into any other part of the coffin, 
    it will not work, 
    and you may have to simply delete the entire object. 
    
1.  Set the script to "no modify" so that people won't be able to 
    mess with the script. 
    
## Notes

I've figured out the math error in the script. 
The script works, as it is so no update will be made unless it's needed.

If we need to redo the script, 
it should be compiled and then new settings applied.
Here are values that should be a close starting point: 

```
1 right out 110 1.5 <0,1,0> <0.125,0,0.04>
```

