<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.util.stream.Collectors" %>
<%@ page import="com.mongodb.client.*, org.bson.Document" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - MatchMate Matrimony</title>
    <style>
        body {margin:0; font-family:'Segoe UI',sans-serif; background:#fff0f5;}
        .header {background:#b22222; color:white; padding:20px; text-align:center; font-size:26px; font-weight:bold;}
        .section {max-width:1100px; margin:30px auto; padding:20px; background:white; border-radius:15px; box-shadow:0 8px 20px rgba(0,0,0,0.1);}
        .section h2 {color:#b22222; border-bottom:2px solid #eee; padding-bottom:10px; margin-bottom:25px;}
        .profile {margin-bottom:20px;}
        .matches {display:grid; grid-template-columns:repeat(auto-fit,minmax(250px,1fr)); gap:20px;}
        .match-card {border:1px solid #ddd; border-radius:12px; padding:15px; background:#fffafa; box-shadow:0 4px 12px rgba(0,0,0,0.07);}
        .match-card h3 {margin-top:0; color:#8b0000;}
        .match-card p {margin:4px 0;}
        .compatibility {margin-top:10px; font-weight:bold; color:#b22222;}
        .actions {margin-top:10px;}
        .actions button {margin-right:8px; padding:8px 14px; border:none; border-radius:6px; cursor:pointer; font-weight:bold; transition:0.3s;}
        .like {background:#28a745; color:white;} .like:hover{background:#218838;}
        .dislike {background:#dc3545; color:white;} .dislike:hover{background:#c82333;}
        .chat {background:#007bff; color:white;} .chat:hover{background:#0056b3;}
    </style>
</head>
<body>

<div class="header">Welcome to MatchMate Matrimony</div>

<div class="section">
    <h2>Your Profile</h2>
    <div class="profile">
        <%
            // Get form data
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String ageStr = request.getParameter("age");
            String gender = request.getParameter("gender");
            String religion = request.getParameter("religion");
            String profession = request.getParameter("profession");
            String location = request.getParameter("location");
            String zodiac = request.getParameter("zodiac");
            String[] interestsArr = request.getParameterValues("interests");

            int age = 0;
            if(ageStr != null && !ageStr.isEmpty()) age = Integer.parseInt(ageStr);

            List<String> userInterests = new ArrayList<>();
            if(interestsArr != null) userInterests = Arrays.asList(interestsArr);

            // Insert into MongoDB directly
            try {
                MongoClient mongoClient = MongoClients.create("mongodb://localhost:27017");
                MongoDatabase db = mongoClient.getDatabase("matchmateDB");
                MongoCollection<Document> usersCol = db.getCollection("users");

                Document userDoc = new Document("name", name)
                    .append("email", email)
                    .append("password", password) // ⚠️ hash in production
                    .append("age", age)
                    .append("gender", gender)
                    .append("religion", religion)
                    .append("profession", profession)
                    .append("location", location)
                    .append("zodiac", zodiac)
                    .append("interests", userInterests);

                usersCol.insertOne(userDoc);

                mongoClient.close();
            } catch(Exception e) {
                out.println("<p style='color:red'>DB Error: "+ e.getMessage() +"</p>");
            }
        %>
        <p><strong>Name:</strong> <%= name %></p>
        <p><strong>Email:</strong> <%= email %></p>
        <p><strong>Age:</strong> <%= age %></p>
        <p><strong>Gender:</strong> <%= gender %></p>
        <p><strong>Religion:</strong> <%= religion %></p>
        <p><strong>Profession:</strong> <%= profession %></p>
        <p><strong>Location:</strong> <%= location %></p>
        <p><strong>Zodiac:</strong> <%= zodiac %></p>
        <p><strong>Interests:</strong> <%= String.join(", ", userInterests) %></p>
    </div>
</div>

<div class="section">
    <h2>Match Suggestions for You</h2>
    <div class="matches">

        <%
            // Dummy profiles
            class Profile {
                String name, gender, religion, profession, location, zodiac;
                int age;
                List<String> interests;

                Profile(String n, String g, int a, String r, String p, String l, String z, List<String> i) {
                    name=n; gender=g; age=a; religion=r; profession=p; location=l; zodiac=z; interests=i;
                }
            }

            List<Profile> profiles = new ArrayList<>();
            profiles.add(new Profile("Priya Sharma","female",24,"Hindu","Software Engineer","Mumbai","Aries",Arrays.asList("Music","Travel")));
            profiles.add(new Profile("Ravi Singh","male",30,"Sikh","Doctor","Delhi","Pisces",Arrays.asList("Books","Movies")));
            profiles.add(new Profile("Sneha Kapoor","female",25,"Sikh","Fashion Designer","Chandigarh","Leo",Arrays.asList("Sports","Music")));
            profiles.add(new Profile("Ayaan Sheikh","male",27,"Muslim","Chartered Accountant","Lucknow","Aries",Arrays.asList("Music","Cooking")));
            profiles.add(new Profile("Kritika Jain","female",23,"Jain","Designer","Delhi","Cancer",Arrays.asList("Movies","Books")));
            profiles.add(new Profile("Arjun Nair","male",29,"Christian","Lawyer","Kochi","Gemini",Arrays.asList("Books","Sports")));
            profiles.add(new Profile("Tanvi Patil","female",22,"Hindu","Architect","Nagpur","Sagittarius",Arrays.asList("Sports","Cooking")));
            profiles.add(new Profile("Neha Verma","female",28,"Hindu","Lawyer","Jaipur","Scorpio",Arrays.asList("Books","Travel")));

            // Zodiac compatibility map
            Map<String,List<String>> comp = new HashMap<>();
            comp.put("Aries",Arrays.asList("Leo","Sagittarius","Gemini","Aquarius"));
            comp.put("Taurus",Arrays.asList("Virgo","Capricorn","Cancer","Pisces"));
            comp.put("Gemini",Arrays.asList("Libra","Aquarius","Aries","Leo"));
            comp.put("Cancer",Arrays.asList("Scorpio","Pisces","Taurus","Virgo"));
            comp.put("Leo",Arrays.asList("Aries","Sagittarius","Gemini","Libra"));
            comp.put("Virgo",Arrays.asList("Taurus","Capricorn","Cancer","Scorpio"));
            comp.put("Libra",Arrays.asList("Gemini","Aquarius","Leo","Sagittarius"));
            comp.put("Scorpio",Arrays.asList("Cancer","Pisces","Virgo","Capricorn"));
            comp.put("Sagittarius",Arrays.asList("Aries","Leo","Libra","Aquarius"));
            comp.put("Capricorn",Arrays.asList("Taurus","Virgo","Scorpio","Pisces"));
            comp.put("Aquarius",Arrays.asList("Gemini","Libra","Aries","Sagittarius"));
            comp.put("Pisces",Arrays.asList("Cancer","Scorpio","Taurus","Capricorn"));

            List<Profile> filtered = new ArrayList<>();
            for(Profile p:profiles){
                if(!p.gender.equalsIgnoreCase(gender) &&
                   comp.getOrDefault(zodiac,new ArrayList<>()).contains(p.zodiac)) {
                    filtered.add(p);
                }
            }

            for(Profile p:filtered){
                int compatibility=0;

                // Age difference score (max 30)
                int ageDiff=Math.abs(age-p.age);
                compatibility+=Math.max(0,30-ageDiff*5);

                // Location match
                if(p.location.equalsIgnoreCase(location)) compatibility+=20;

                // Shared interests
                List<String> shared=new ArrayList<>(userInterests);
                shared.retainAll(p.interests);
                compatibility+=shared.size()*5;

                // Zodiac bonus
                compatibility+=25;
        %>
        <div class="match-card">
            <h3><%=p.name%></h3>
            <p>Age: <%=p.age%></p>
            <p>Profession: <%=p.profession%></p>
            <p>Religion: <%=p.religion%></p>
            <p>Location: <%=p.location%></p>
            <p>Zodiac: <%=p.zodiac%></p>
            <p>Interests: <%=String.join(", ",p.interests)%></p>
            <p class="compatibility">Compatibility Score: <%=compatibility%>%</p>
            <div class="actions">
                <button class="like">Like</button>
                <button class="dislike">Dislike</button>
                <button class="chat">Chat</button>
            </div>
        </div>
        <% } %>
    </div>
</div>

</body>
</html>
