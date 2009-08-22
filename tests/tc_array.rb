require 'test/unit'
require 'pdns'

class TC_ArrayTests < Test::Unit::TestCase
    def test_if_data_is_shuffled
        first = [1,2,3,4]
        second = [1,2,3,4]

        assert_not_equal first, second.shuffle!, "Array should be shuffled"
    end

    def test_if_random_chooses_random_data
        data = [1, 2, 3, 4, 5]
        res = []

        data.size.times do 
            res << data.random
        end

        assert_not_equal data, res, "Arrays should not be the same"
    end

    def test_if_randomize_randomizes
        data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
        result = data.randomize

        assert_not_equal data, data.randomize, "Arrays should not be the same"
        assert_equal data.size, result.size, "Arrays should contain the same amount of entries"
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
