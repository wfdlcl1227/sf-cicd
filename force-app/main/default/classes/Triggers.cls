public class Triggers {

	public enum Evt {
		afterdelete, afterinsert, afterundelete,
		afterupdate, beforedelete, beforeinsert, beforeupdate
	}

	public interface Handler {
	  	void handle();
	}

	Map<String, List<Handler>> eventHandlerMapping = new Map<String, List<Handler>>();

	public Triggers bind(Evt event, Handler eh) {
	  	List<Handler> handlers = eventHandlerMapping.get(event.name());
	  	if (handlers == null) {
	    	handlers = new List<Handler>();
	    	eventHandlerMapping.put(event.name(), handlers);
	  	}
	  	handlers.add(eh);
	  	return this;
	}

	public void manage() {
	    Evt ev = null;
	    if(Trigger.isInsert && Trigger.isBefore){
	        ev = Evt.beforeinsert;
	    } else if(Trigger.isInsert && Trigger.isAfter){
	        ev = Evt.afterinsert;
	    } else if(Trigger.isUpdate && Trigger.isBefore){
	        ev = Evt.beforeupdate;
	    } else if(Trigger.isUpdate && Trigger.isAfter){
	        ev = Evt.afterupdate;
	    } else if(Trigger.isDelete && Trigger.isBefore){
	        ev = Evt.beforedelete;
	    } else if(Trigger.isDelete && Trigger.isAfter){
	        ev = Evt.afterdelete;
	    } else if(Trigger.isundelete){
	        ev = Evt.afterundelete;
	    }
	    List<Handler> handlers = eventHandlerMapping.get(ev.name());
	    if (handlers != null && !handlers.isEmpty()) {
	      	for (Handler h : handlers) {
	      		/*
	      		Type handlerType = Type.forName(String.valueOf(h).substringBefore(':'));
	      		Type ruleHandlerType = Type.forName('NEO_Rules_Handler');

	      		if (!NEO_Rules_Constants.NEO_TRIGGER_HANDLER_SWITCH && 
	      			!ruleHandlerType.isAssignableFrom(handlerType)) {
	      			continue;
	      		}
	      		*/
	        	h.handle();
	      	}
	    }
	}
}