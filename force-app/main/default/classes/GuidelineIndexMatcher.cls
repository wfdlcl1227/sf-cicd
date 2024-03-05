public class GuidelineIndexMatcher {

    public static void main() {
        String targetString = 'Cluster001-Brand001-SKU001-Province001-Terminal001';
        String matchString1 = '?-?-?-Province001-Terminal001';
        String matchString2 = 'Cluster001-?-?-Province001-Terminal001';
        String matchString3 = 'Cluster002-Brand001-?-Province001-Terminal001';

        String mostSimilarString = findMostSimilarString(targetString, new List<String>{matchString1, matchString2, matchString3});

        System.debug('Most Similar String: ' + mostSimilarString);
    }

    private static String findMostSimilarString(String target, List<String> matches) {
        Integer minDistance = 10000000;
        String mostSimilarString = '';

        for (String match : matches) {
            Integer distance = calculateSimpleDistance(target, match);

            if (distance < minDistance ) {
                minDistance = distance;
                mostSimilarString = match;
            }
        }

        return mostSimilarString;
    }

    private static Integer calculateSimpleDistance(String s1, String s2) {
        String[] targetParts = s1.split('-');
        String[] matchParts = s2.split('-');

        Integer distance = 100;


        System.debug('s1: ' + s1);
        System.debug('s2: ' + s2);

        for (Integer i = 0; i < targetParts.size(); i++) {
            

            if (matchParts[i].equalsIgnoreCase(targetParts[i])) {
            //与 Target Part 相等，则距离为0
                distance = distance + 0;
            }else if(matchParts[i] == '?'){
             //如果 Match Part 为 "?" 则距离为1
                distance = distance + 1;
            }else{
            //如果 Match Part 相等 则距离为2
                distance = distance + 2;
               
            }
            
        }

        System.debug('distance: '+s2+':' + distance);


        return distance;
    }
}