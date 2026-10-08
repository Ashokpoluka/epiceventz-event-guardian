/**
 * @description Enterprise Apex Trigger Handler Base Framework with Recursion Prevention & Security Context.
 * @group EpicEventz Apex Framework
 */
public virtual class TriggerHandler {
    
    // Static set to prevent recursive trigger execution
    private static Set<String> reentrancyGuard = new Set<String>();

    public static Boolean isFirstRun(String handlerName) {
        if (reentrancyGuard.contains(handlerName)) {
            return false;
        } else {
            reentrancyGuard.add(handlerName);
            return true;
        }
    }

    public static void clearReentrancyGuard(String handlerName) {
        reentrancyGuard.remove(handlerName);
    }
}
