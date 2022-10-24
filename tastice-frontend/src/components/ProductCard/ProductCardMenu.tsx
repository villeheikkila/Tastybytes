import { useApolloClient, useMutation } from '@apollo/react-hooks';
import { Menu, MenuItem } from '@material-ui/core';
import { bindMenu } from 'material-ui-popup-state/hooks';
import React, { useState } from 'react';
import useReactRouter from 'use-react-router';
import { DELETE_PRODUCT, SEARCH_CHECKINS, SEARCH_PRODUCTS } from '../../graphql';
import { ConfirmationDialog } from '../ConfirmationDialog';

export interface ProductCardMenuProps {
    setShowEditProduct: any;
    menuState: any;
    id: string;
    name: string;
}

export const ProductCardMenu = ({ id, name, menuState, setShowEditProduct }: ProductCardMenuProps): JSX.Element => {
    const [visible, setVisible] = useState(false);
    const client = useApolloClient();
    const { history } = useReactRouter();

    const [deleteProduct] = useMutation(DELETE_PRODUCT, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [
            { query: SEARCH_CHECKINS, variables: { filter: '' } },
            { query: SEARCH_PRODUCTS, variables: { filter: '' } },
        ],
    });

    const handleDeleteProduct = async (): Promise<void> => {
        setVisible(false);
        const result = await deleteProduct({
            variables: { id },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `Product ${result.data.deleteProduct.name} succesfully deleted`,
                    variant: 'success',
                },
            });
            history.push(`/activity`);
        }
    };

    return (
        <>
            <Menu {...bindMenu(menuState)}>
                <MenuItem
                    onClick={(): void => {
                        menuState.close();
                        setShowEditProduct(true);
                    }}
                >
                    Edit Product
                </MenuItem>
                <MenuItem
                    onClick={(): void => {
                        menuState.close();
                        setVisible(true);
                    }}
                >
                    Remove Product
                </MenuItem>
            </Menu>

            <ConfirmationDialog
                visible={visible}
                setVisible={setVisible}
                description={'HEEII'}
                title={'Warning!'}
                content={`Are you sure you want to remove ${name}`}
                onAccept={handleDeleteProduct}
                declineButton={'Cancel'}
                acceptButton={'Yes'}
            />
        </>
    );
};
