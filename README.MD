# Controller Collection View
### Experimenting with creating a reusable controller collection view to simplify collections within collections.  

The goal behind this project was to explore ways to simplify complex collections while maintaining good code architecture.  For me the most common use case for this is nested collection views, but there are plenty of other scenarios where this can be useful.  The controller collection view acts as a wrapper around a regular collection view and allows you to use and reuse view controllers just as you would a collection view cell.  

You'll get the most benefit when using it on view controllers that are centered around a singular model object.  For example if you have a collection of photo collections and each view controller displays its own photo collection in a regular collection view.  

### Usage
Create a child view controller that displays a photo collection, then in the controllerForItemAtIndexPath method of the datasource dequeue one of your child view controllers and pass in a photo collection.  The same way you would with a collection view.    Don't forget to implement prepareForReuse() on your child view controller to handle any necessary teardown.  
