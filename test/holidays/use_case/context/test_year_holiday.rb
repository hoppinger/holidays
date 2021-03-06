require File.expand_path(File.dirname(__FILE__)) + '/../../../test_helper'

require 'holidays/use_case/context/year_holiday'

class YearHolidayTests < Test::Unit::TestCase
  def setup
    @definition_search = mock()

    @subject = Holidays::UseCase::Context::YearHoliday.new(
      @definition_search,
    )

    @from_date= Date.civil(2015, 1, 1)
    @dates_driver = {2015 => [0, 1, 2], 2014 => [0, 12]}
    @regions = [:us]
    @observed = false
    @informal = false

    @definition_search.expects(:call).at_most_once.with(
      @dates_driver,
      @regions,
      [],
    ).returns([{
      :date => Date.civil(2015, 1, 1),
      :name => "Test",
      :regions => [:us],
    }])
  end

  def test_returns_error_if_from_date_is_missing
    assert_raise ArgumentError do
      @subject.call(nil, @dates_driver, @regions, @observed, @informal)
    end
  end

  def test_returns_error_if_from_date_is_not_a_date
    assert_raise ArgumentError do
      @subject.call("2015-1-1", @dates_driver, @regions, @observed, @informal)
    end
  end

  def test_returns_error_if_date_driver_is_missing_or_empty
    assert_raise ArgumentError do
      @subject.call(@from_date, nil, @regions, @observed, @informal)
    end

    assert_raise ArgumentError do
      @subject.call(@from_date, {}, @regions, @observed, @informal)
    end
  end

  def test_returns_error_if_date_driver_contains_nil_or_empty_months
    bad_dates_driver = {2015 => [0, 1, 2], 2014 => []}

    assert_raise ArgumentError do
      @subject.call(@from_date, bad_dates_driver, @regions, @observed, @informal)
    end

    bad_dates_driver = {2015 => [0, 1, 2], 2014 => nil}

    assert_raise ArgumentError do
      @subject.call(@from_date, bad_dates_driver, @regions, @observed, @informal)
    end
  end

  def test_returns_error_if_regions_is_missing_or_empty
    assert_raise ArgumentError do
      @subject.call(@from_date, @dates_driver, nil, @observed, @informal)
    end

    assert_raise ArgumentError do
      @subject.call(@from_date, @dates_driver, [], @observed, @informal)
    end
  end

  def test_returns_single_holiday
    assert_equal(
      [
        {
          :date => Date.civil(2015, 1, 1),
          :name => "Test",
          :regions => [:us],
        }
      ],
      @subject.call(@from_date, @dates_driver, @regions, @observed, @informal)
    )
  end

  def test_returns_multiple_holidays_in_a_year
    @definition_search.expects(:call).at_most_once.with(
      @dates_driver,
      @regions,
      [],
    ).returns([
      {
        :date => Date.civil(2015, 1, 1),
        :name => "Test",
        :regions => [:us],
      },
      {
        :date => Date.civil(2015, 2, 1),
        :name => "Test",
        :regions => [:us],
      },
      {
        :date => Date.civil(2015, 12, 1),
        :name => "Test",
        :regions => [:us],
      },
      ]
    )

    assert_equal(
      [
        {
          :date => Date.civil(2015, 1, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 2, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 12, 1),
          :name => "Test",
          :regions => [:us],
        }
      ],
      @subject.call(@from_date, @dates_driver, @regions, @observed, @informal)
    )
  end

  def test_returns_multiple_holidays_filters_dates_outside_of_year
    @definition_search.expects(:call).at_most_once.with(
      @dates_driver,
      @regions,
      [],
    ).returns([
      {
        :date => Date.civil(2015, 1, 1),
        :name => "Test",
        :regions => [:us],
      },
      {
        :date => Date.civil(2015, 2, 1),
        :name => "Test",
        :regions => [:us],
      },
      {
        :date => Date.civil(2016, 12, 1),
        :name => "Test",
        :regions => [:us],
      },
      ]
    )

    assert_equal(
      [
        {
          :date => Date.civil(2015, 1, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 2, 1),
          :name => "Test",
          :regions => [:us],
        },
      ],
      @subject.call(@from_date, @dates_driver, @regions, @observed, @informal)
    )
  end

  def test_returns_sorted_multiple_holidays
    @definition_search.expects(:call).at_most_once.with(
      @dates_driver,
      @regions,
      [],
    ).returns(
      [
        {
          :date => Date.civil(2015, 1, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 12, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 2, 1),
          :name => "Test",
          :regions => [:us],
        },
      ]
    )

    assert_equal(
      [
        {
          :date => Date.civil(2015, 1, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 2, 1),
          :name => "Test",
          :regions => [:us],
        },
        {
          :date => Date.civil(2015, 12, 1),
          :name => "Test",
          :regions => [:us],
        }
      ],
      @subject.call(@from_date, @dates_driver, @regions, @observed, @informal)
    )
  end
end
