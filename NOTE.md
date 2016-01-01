

When you create and add a document to controller, don't forget this.
Or just use `openUntitledDocumentAndDisplay`.

>	The default implementation of this method calls defaultType to determine the type of new document to create, 
> 	calls makeUntitledDocumentOfType:error: to create it, then calls addDocument: to record its opening. If 
>	displayDocument is YES, it then sends the new document makeWindowControllers and showWindows messages.




See "Text System Defaults and Key Bindings" to override text system defaults and keys.



Naming Convention
-----------------
Types ends with `~Tool` are one-time use only objects.
