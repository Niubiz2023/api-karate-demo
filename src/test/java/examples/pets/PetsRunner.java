package examples.pets;
import com.intuit.karate.junit5.Karate;

public class PetsRunner {

    @Karate.Test
    Karate testPets() {
        return Karate.run("pets").relativeTo(getClass());
    }
}

