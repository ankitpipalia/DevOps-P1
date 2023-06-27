import React, { useState, useEffect } from "react";
import { Button, Container, Form, Modal, Table } from "react-bootstrap";
import { useTable } from "react-table";
import axios from "axios";


import "./App.css";
axios.defaults.baseURL='https://ankitbackend.centralus.cloudapp.azure.com';
function App() {
  const [familyMembers, setFamilyMembers] = useState([]);
  const [newMember, setNewMember] = useState({
    id: "",
    name: "",
    father: "",
    mother: "",
    surname: "",
    dob: "",
  });
  const [updateMember, setUpdateMember] = useState({
    updateid: newMember.updateid,
    updatename: newMember.name,
    updatefather: newMember.father,
    updatemother: newMember.mother,
    updatesurname: newMember.surname,
    updatedob: newMember.dob,
  });
  const [showModal, setShowModal] = useState(false);
  const [actualUpdatingId, setActualUpdatingId] = useState();
  const columns = React.useMemo(
    () => [
      {
        Header: "First Name",
        accessor: "name",
      },
      {
        Header: "Father Name",
        accessor: "father",
      },
      {
        Header: "Mother Name",
        accessor: "mother",
      },
      {
        Header: "Surname",
        accessor: "surname",
      },
      {
        Header: "Date Of Birth",
        accessor: "dob",
      },
      {
        Header: "Actions",
        accessor: "actions",
        Cell: (row) => (
          <div>
            <Button
              variant="info"
              size="sm"
              onClick={() => handleOpenModal(row.cell.row.original.id)}
            >
              Edit
            </Button>{" "}
            <Button
              variant="danger"
              size="sm"
              onClick={() => handleDelete(row.cell.row.original.id)}
            >
              Delete
            </Button>
          </div>
        ),
      },
    ],
    []
  );
  const data = [...familyMembers];
  const tableInstance = useTable({ columns, data });
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = tableInstance;

  useEffect(() => {
    const getFamilyMembers = async () => {
      const res = await axios.get(
        `/users`
      );
      setFamilyMembers(res.data);
    };
    getFamilyMembers();
  }, []);

  const handleChange = (e) => {
    setNewMember({
      ...newMember,
      [e.target.name]: e.target.value,
    });
  };

  const handleChangeOnUpdating = (e) => {
    setUpdateMember({
      ...updateMember,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const res = await axios.post(
      `/users`,
      newMember
    );
    if (res.data.name === "error") alert("This member already exists");
    else {
      alert("A new family member has been created");
      const res = await axios.get(
        `/users`
      );
      setFamilyMembers(res.data);
    }
  };

  const handleUpdate = async (e) => {
    e.preventDefault();
    const res = await axios.put(
      `/users/` +
        actualUpdatingId,
      {
        id: updateMember.updateid,
        name: updateMember.updatename,
        father: updateMember.updatefather,
        mother: updateMember.updatemother,
        surname: updateMember.updatesurname,
        dob: updateMember.updatedob,
      }
    );
    if (res.data.name === "error") alert("This member already exists");
    else {
      alert("A new family member has been updated");
      const res = await axios.get(
        `/users`
      );
      setFamilyMembers(res.data);
      handleCloseModal();
    }
  };

  const handleOpenModal = (id) => {
    setShowModal(true);
    setActualUpdatingId(id);
  };

  const handleCloseModal = () => {
    setShowModal(false);
  };

  const handleDelete = async (id) => {
    console.log(id);
    await axios.delete(
      `/users/` +
        id
    );
    alert("A family member has been deleted");
    const res = await axios.get(
      `/users`
    );
    setFamilyMembers(res.data);
  };

  return (
    <Container fluid="sm" className="p-3">
      <h1>Family Details</h1>

      <Form onSubmit={handleSubmit}>
        <Form.Group controlId="">
          <Form.Label>First Name:</Form.Label>
          <Form.Control
            name="name"
            value={newMember.name}
            type="text"
            onChange={handleChange}
          />
        </Form.Group>

        <Form.Group controlId="">
          <Form.Label>Father's Name:</Form.Label>
          <Form.Control
            name="father"
            value={newMember.father}
            type="text"
            onChange={handleChange}
          >
          </Form.Control>

          <Form.Label>Mother's Name:</Form.Label>
          <Form.Control
            name="mother"
            value={newMember.mother}
            onChange={handleChange}
            type="text"
          >
          </Form.Control>

          <Form.Label>Surname:</Form.Label>
          <Form.Control
            name="surname"
            value={newMember.surname}
            onChange={handleChange}
            type="text"
          >
          </Form.Control>

          <Form.Group controlId="date">
            <Form.Label>Date Of Birth</Form.Label>
            <Form.Control
              name="dob"
              value={newMember.dob ? new Date(newMember.dob).toISOString().split('T')[0] : ''}
              onChange={handleChange}
              type="date"
            />
          </Form.Group>
          

          <Button type="submit">Create a new family member!</Button>
        </Form.Group>
      </Form>

      <h2>The members of the family are just here</h2>
      <Table responsive="lg" striped bordered hover {...getTableProps()}>
        <thead>
          {headerGroups.map((headerGroup) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column) => (
                <th {...column.getHeaderProps()}>{column.render("Header")}</th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map((row, i) => {
            prepareRow(row);
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => {
                  return (
                    <td {...cell.getCellProps()}>{cell.render("Cell")}</td>
                  );
                })}
              </tr>
            );
          })}
        </tbody>
      </Table>

      <Modal show={showModal} onHide={handleCloseModal}>
        <Modal.Header closeButton>
          <Modal.Title>Let's update this person</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form onSubmit={handleUpdate}>
            <Form.Group>
              <Form.Label>First Name: </Form.Label>
              <Form.Control
                name="updatename"
                value={updateMember.updatename}
                type="text"
                onChange={handleChangeOnUpdating}
              />
            </Form.Group>

            <Form.Group>
              <Form.Label>Father Name: </Form.Label>
              <Form.Control
                name="updatefather"
                value={updateMember.updatefather}
                onChange={handleChangeOnUpdating}
                type="text"
              >
              </Form.Control>

              <Form.Label>Mother Name: </Form.Label>
              <Form.Control
                name="updatemother"
                value={updateMember.updatemother}
                onChange={handleChangeOnUpdating}
                type="text"
              >
              </Form.Control>

              <Form.Label>Surname: </Form.Label>
              <Form.Control
                name="updatesurname"
                value={updateMember.updatesurname}
                onChange={handleChangeOnUpdating}
                type="text"
              >
              </Form.Control>

              <Form.Group>
                <Form.Label>Date Of Birth </Form.Label>
                <Form.Control
                  name="updatedob"
                  value={updateMember.updatedob}
                  onChange={handleChangeOnUpdating}
                  type="date"
                />
              </Form.Group>
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleCloseModal}>
            Close
          </Button>
          <Button type="submit" onClick={handleUpdate} variant="primary">
            Save Changes
          </Button>
        </Modal.Footer>
      </Modal>
    </Container>
  );
}

export default App;