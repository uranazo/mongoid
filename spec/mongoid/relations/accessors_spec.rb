require "spec_helper"

describe Mongoid::Relations::Accessors do

  describe "\#{getter}?" do

    let(:person) do
      Person.create
    end

    context "when the relation is a has one" do

      context "when the relation exists" do

        let!(:game) do
          person.build_game
        end

        it "returns true" do
          expect(person).to have_game
        end
      end

      context "when the relation does not exist" do

        context "when not autobuilding" do

          it "returns false" do
            expect(person).to_not have_game
          end
        end

        context "when autobuilding" do

          it "returns false" do
            expect(person).to_not have_book
          end
        end
      end
    end

    context "when the relation is a has many" do

      context "when the relation has documents" do

        let!(:post) do
          person.posts.build
        end

        it "returns true" do
          expect(person).to have_posts
        end
      end

      context "when the relation does not have documents" do

        it "returns false" do
          expect(person).to_not have_posts
        end
      end
    end

    context "when the relation is a has and belongs to many" do

      context "when the relation has documents" do

        let!(:preference) do
          person.preferences.build
        end

        it "returns true" do
          expect(person).to have_preferences
        end
      end

      context "when the relation does not have documents" do

        it "returns false" do
          expect(person).to_not have_preferences
        end
      end
    end

    context "when the relation is a belongs to" do

      context "when the relation is named next" do

        let(:user) do
          User.create
        end

        it "allows the existence check" do
          expect(user).to_not have_next
        end
      end

      context "when the relation exists" do

        let!(:game) do
          person.build_game
        end

        it "returns true" do
          expect(game).to have_person
        end
      end

      context "when the relation does not exist" do

        context "when the relation does not autobuild" do

          let(:game) do
            Game.new
          end

          it "returns false" do
            expect(game).to_not have_person
          end
        end

        context "when the relation autobuilds" do

          let(:book) do
            Book.new
          end

          it "returns false" do
            expect(book).to_not have_person
          end
        end
      end
    end

    context "when the relation is an embeds one" do

      context "when the relation exists" do

        let!(:name) do
          person.build_name
        end

        it "returns true" do
          expect(person).to have_name
        end
      end

      context "when the relation does not exist" do

        context "when the relation does not autobuild" do

          it "returns false" do
            expect(person).to_not have_name
          end
        end

        context "when the relation autobuilds" do

          let(:person) do
            Person.new
          end

          it "returns false" do
            expect(person).to_not have_passport
          end
        end
      end
    end

    context "when the relation is an embeds many" do

      context "when the relation has documents" do

        let!(:address) do
          person.addresses.build
        end

        it "returns true" do
          expect(person).to have_addresses
        end
      end

      context "when the relation does not have documents" do

        it "returns false" do
          expect(person).to_not have_addresses
        end
      end
    end

    context "when the relation is an embedded in" do

      context "when the relation exists" do

        let!(:name) do
          person.build_name
        end

        it "returns true" do
          expect(name).to have_namable
        end
      end

      context "when the relation does not exist" do

        context "when the relation does not autobuild" do

          let(:name) do
            Name.new
          end

          it "returns false" do
            expect(name).to_not have_namable
          end
        end

        context "when the relation autobuilds" do

          let(:passport) do
            Passport.new
          end

          it "returns false" do
            expect(passport).to_not have_person
          end
        end
      end
    end
  end

  describe "\#{getter}" do

    let(:person) do
      Person.new
    end

    context "when autobuilding the relation" do

      context "when the relation is an embeds one" do

        context "when the relation does not exist" do

          let!(:passport) do
            person.passport
          end

          it "builds the new document" do
            expect(passport).to be_a(Passport)
          end

          it "stores in the altered attribute" do
            expect(person.as_document["pass"]).to eq(passport.attributes)
          end
        end

        context "when the relation exists" do

          let!(:passport) do
            person.build_passport(number: "123123321")
          end

          it "does not build a new document" do
            expect(person.passport).to eq(passport)
          end
        end
      end

      context "when the relation is an embedded in" do

        let(:passport) do
          Passport.new
        end

        context "when the relation does not exist" do

          let(:person) do
            passport.person
          end

          it "builds the new document" do
            expect(person).to be_a(Person)
          end
        end

        context "when the relation exists" do

          let!(:person) do
            passport.build_person(title: "sir")
          end

          it "does not build a new document" do
            expect(passport.person).to eq(person)
          end
        end
      end

      context "when the relation is a has one" do

        context "when the relation does not exist" do

          let(:book) do
            person.book
          end

          it "builds the new document" do
            expect(book).to be_a(Book)
          end
        end

        context "when the relation exists" do

          let!(:book) do
            person.build_book(title: "art of war")
          end

          it "does not build a new document" do
            expect(person.book).to eq(book)
          end
        end
      end

      context "when the relation is a belongs to" do

        let(:book) do
          Book.new
        end

        context "when the relation does not exist" do

          let(:person) do
            book.person
          end

          it "builds the new document" do
            expect(person).to be_a(Person)
          end
        end

        context "when the relation exists" do

          let!(:person) do
            book.build_person(title: "sir")
          end

          it "does not build a new document" do
            expect(book.person).to eq(person)
          end
        end
      end
    end

    context "when the relation is not polymorphic" do

      let(:person) do
        Person.create
      end

      context "when the relation is a many to many" do

        let!(:preference) do
          Preference.create(name: "Setting")
        end

        before do
          person.preferences << Preference.last
        end

        context "when reloading the relation directly" do

          let(:preferences) do
            person.preferences(true)
          end

          it "reloads the correct documents" do
            expect(preferences).to eq([ preference ])
          end

          it "reloads a new instance" do
            expect(preferences.first).to_not equal(preference)
          end
        end

        context "when reloading via the base document" do

          let(:preferences) do
            person.reload.preferences
          end

          it "reloads the correct documents" do
            expect(preferences).to eq([ preference ])
          end

          it "reloads a new instance" do
            expect(preferences.first).to_not equal(preference)
          end
        end

        context "when performing a fresh find on the base" do

          let(:preferences) do
            Person.find(person.id).preferences
          end

          it "reloads the correct documents" do
            expect(preferences).to eq([ preference ])
          end
        end
      end

      context "when the relation is a many to one" do

        let!(:post) do
          Post.create(title: "First!")
        end

        before do
          person.posts << Post.last
        end

        context "when reloading the relation directly" do

          let(:posts) do
            person.posts(true)
          end

          it "reloads the correct documents" do
            expect(posts).to eq([ post ])
          end

          it "reloads a new instance" do
            expect(posts.first).to_not equal(post)
          end
        end

        context "when reloading via the base document" do

          let(:posts) do
            person.reload.posts
          end

          it "reloads the correct documents" do
            expect(posts).to eq([ post ])
          end

          it "reloads a new instance" do
            expect(posts.first).to_not equal(post)
          end
        end

        context "when performing a fresh find on the base" do

          let(:posts) do
            Person.find(person.id).posts
          end

          it "reloads the correct documents" do
            expect(posts).to eq([ post ])
          end
        end
      end

      context "when the relation is a references one" do

        let!(:game) do
          Game.create(name: "Centipeded")
        end

        before do
          person.game = Game.last
        end

        context "when reloading the relation directly" do

          let(:reloaded_game) do
            person.game(true)
          end

          it "reloads the correct documents" do
            expect(reloaded_game).to eq(game)
          end

          it "reloads a new instance" do
            expect(reloaded_game).to_not equal(game)
          end
        end

        context "when reloading via the base document" do

          let(:reloaded_game) do
            person.reload.game
          end

          it "reloads the correct documents" do
            expect(reloaded_game).to eq(game)
          end

          it "reloads a new instance" do
            expect(reloaded_game).to_not equal(game)
          end
        end

        context "when performing a fresh find on the base" do

          let(:reloaded_game) do
            Person.find(person.id).game
          end

          it "reloads the correct documents" do
            expect(reloaded_game).to eq(game)
          end
        end
      end
    end

    context "when the relation is polymorphic" do

      context "when there's a single references many/one" do

        let!(:movie) do
          Movie.create(title: "Inception")
        end

        let!(:book) do
          Book.create(title: "Jurassic Park")
        end

        let!(:movie_rating) do
          movie.ratings.create(value: 10)
        end

        let!(:book_rating) do
          book.create_rating(value: 5)
        end

        context "when accessing a referenced in" do

          let!(:rating) do
            Rating.where(value: 10).first
          end

          it "returns the correct document" do
            expect(rating.ratable).to eq(movie)
          end
        end

        context "when accessing a references many" do

          let(:ratings) do
            Movie.first.ratings
          end

          it "returns the correct documents" do
            expect(ratings).to eq([ movie_rating ])
          end
        end

        context "when accessing a references one" do

          let!(:rating) do
            Book.find(book.id).rating
          end

          it "returns the correct document" do
            expect(rating).to eq(book_rating)
          end
        end
      end

      context "when there are multiple references many/one" do

        let(:face) do
          Face.create
        end

        let(:eye_bowl) do
          EyeBowl.create
        end

        let!(:face_left_eye) do
          face.create_left_eye(pupil_dilation: 10)
        end

        let!(:face_right_eye) do
          face.create_right_eye(pupil_dilation: 5)
        end

        let!(:eye_bowl_blue_eye) do
          eye_bowl.blue_eyes.create(pupil_dilation: 2)
        end

        let!(:eye_bowl_brown_eye) do
          eye_bowl.brown_eyes.create(pupil_dilation: 1)
        end

        context "when accessing a referenced in" do

          let(:eye) do
            Eye.where(pupil_dilation: 10).first
          end

          it "returns the correct type" do
            expect(eye.eyeable).to be_a(Face)
          end

          it "returns the correct document" do
            expect(eye.eyeable).to eq(face)
          end
        end

        context "when accessing a references many" do

          context "first references many" do

            let(:eyes) do
              EyeBowl.first.blue_eyes
            end

            it "returns the correct documents" do
              expect(eyes).to eq([ eye_bowl_blue_eye ])
            end
          end

          context "second references many" do

            let(:eyes) do
              EyeBowl.first.brown_eyes
            end

            it "returns the correct documents" do
              expect(eyes).to eq([ eye_bowl_brown_eye ])
            end
          end
        end

        context "when accessing a references one" do

          context "first references one" do

            let(:eye) do
              Face.first.left_eye
            end

            it "returns the correct document" do
              expect(eye).to eq(face_left_eye)
            end
          end

          context "second references one" do

            let(:eye) do
              Face.first.right_eye
            end

            it "returns the correct document" do
              expect(eye).to eq(face_right_eye)
            end
          end
        end
      end
    end
  end

  context "when setting relations to empty values" do

    context "when the document is a referenced in" do

      let(:post) do
        Post.new
      end

      context "when setting the relation directly" do

        before do
          post.person = ""
        end

        it "converts them to nil" do
          expect(post.person).to be_nil
        end
      end

      context "when setting the foreign key" do

        before do
          post.person_id = ""
        end

        it "converts it to nil" do
          expect(post.person_id).to be_nil
        end
      end
    end

    context "when the document is a references one" do

      let(:person) do
        Person.new
      end

      context "when setting the relation directly" do

        before do
          person.game = ""
        end

        it "converts them to nil" do
          expect(person.game).to be_nil
        end
      end

      context "when setting the foreign key" do

        let(:game) do
          Game.new
        end

        before do
          game.person_id = ""
        end

        it "converts it to nil" do
          expect(game.person_id).to be_nil
        end
      end
    end

    context "when the document is a references many" do

      let(:person) do
        Person.new
      end

      context "when setting the foreign key" do

        let(:post) do
          Post.new
        end

        before do
          post.person_id = ""
        end

        it "converts it to nil" do
          expect(post.person).to be_nil
        end
      end

      context "when setting the _ids accessor" do

        let(:post) do
          Post.create
        end

        before do
          person.post_ids = [ "" ]
        end

        it "ignore blank values" do
          expect(person.post_ids).to be_empty
        end
      end
    end

    context "when the document is a references many to many" do

      let(:person) do
        Person.new
      end

      context "when setting the foreign key" do

        before do
          person.preference_ids = [ "", "" ]
        end

        it "does not add them" do
          expect(person.preference_ids).to be_empty
        end
      end
    end
  end

  context "when setting association foreign keys" do

    let(:game) do
      Game.new
    end

    let(:person) do
      Person.create
    end

    context "when value is an empty string" do

      before do
        game.person_id = ""
        game.save
      end

      it "sets the foreign key to empty" do
        expect(game.reload.person_id).to be_blank
      end
    end

    context "when value is a populated string" do

      before do
        game.person_id = person.id.to_s
        game.save
      end

      it "sets the foreign key as ObjectID" do
        expect(game.reload.person_id).to eq(person.id)
      end
    end

    context "when value is a ObjectID" do

      before do
        game.person_id = person.id
        game.save
      end

      it "keeps the the foreign key as ObjectID" do
        expect(game.reload.person_id).to eq(person.id)
      end
    end
  end
end
