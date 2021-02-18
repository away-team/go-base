package data_test

import (
	"errors"
	"testing"

	"github.com/divideandconquer/go-consul-client/src/balancer"
	"github.com/golang/mock/gomock"
	"github.com/stretchr/testify/require"

	"github.com/HqOapp/foo-service/src/internal/data"
	"github.com/HqOapp/go-service/alice/middleware"
)

func TestUnitGet(t *testing.T) {
	var (
		serviceSearch = balancer.ServiceLocation{URL: "www.google.com", Port: 1234}
		ctrl          = gomock.NewController(t)
		fakeDNS       = map[string]*balancer.ServiceLocation{
			"Search-db":  &serviceSearch,
			"Friendster": &serviceSearch,
		}
		mockLB = balancer.NewMockDNSBalancer(fakeDNS)
	)

	defer ctrl.Finish()

	tests := map[string]struct {
		serviceName string
		expectedErr error
		validate    func(t *testing.T, db data.Database, expectedErr, actualErr error)
	}{
		"Happy Path": {
			serviceName: "Search",
			validate: func(t *testing.T, db data.Database, expectedErr, actualErr error) {
				require.NoError(t, actualErr)
				require.NotNil(t, db)
			},
		},
		"Service Not Available": {
			serviceName: "NotThere",
			expectedErr: errors.New("Could not find NotThere-db"),
			validate: func(t *testing.T, db data.Database, expectedErr, actualErr error) {
				require.Error(t, actualErr)
				require.Equal(t, expectedErr, actualErr)
				require.Nil(t, db)
			},
		},
	}

	for name, tc := range tests {
		t.Run(name, func(t *testing.T) {
			// todo: mock?
			log := middleware.GetDefaultLogger(tc.serviceName, "local", 7) // 7 is the most verbose

			dbFactory := data.GetDBFactory(mockLB, "dbUser", "dbPass", tc.serviceName, log)
			db, err := dbFactory.Get()
			tc.validate(t, db, tc.expectedErr, err)
		})
	}
}
